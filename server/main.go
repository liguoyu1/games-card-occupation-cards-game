package main

import (
	"crypto/rand"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"sync"
	"time"

	"github.com/gorilla/websocket"
)

func genID() string {
	b := make([]byte, 4)
	rand.Read(b)
	return hex.EncodeToString(b)
}

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

type Msg struct {
	Type    string          `json:"type"`
	Payload json.RawMessage `json:"payload,omitempty"`
}

type Player struct {
	ID     string
	Conn   *websocket.Conn
	RoomID string
	Alive  bool
}

type Room struct {
	ID       string
	Player1 *Player
	Player2 *Player
	mu      sync.RWMutex
}

var (
	rooms    = make(map[string]*Room)
	queue   = make([]*Player, 0)
	queueMu sync.Mutex
)

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/", rootHandler)
	http.HandleFunc("/ws", wsHandler)

	log.Printf("🎴 职业卡牌服务器 :%s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal(err)
	}
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("ok"))
}

func rootHandler(w http.ResponseWriter, r *http.Request) {
	w.Write([]byte("职业卡牌服务器 v1.0\n"))
}

func wsHandler(w http.ResponseWriter, r *http.Request) {
	conn, err := upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Println("upgrade:", err)
		return
	}

	player := &Player{
		ID:    genID(),
		Conn:  conn,
		Alive: true,
	}

	fmt.Printf("[+] 玩家: %s\n", player.ID)

	go handlePlayer(player)
}

func handlePlayer(p *Player) {
	defer func() {
		removeFromQueue(p)
		leaveRoom(p)
		p.Conn.Close()
	}()

	// 心跳
	pingTicker := time.NewTicker(30 * time.Second)
	defer pingTicker.Stop()

	for {
		var msg Msg
		err := p.Conn.ReadJSON(&msg)
		if err != nil {
			fmt.Printf("[-] 玩家 %s 断开\n", p.ID)
			return
		}

		handleMsg(p, msg)
	}
}

func handleMsg(p *Player, msg Msg) {
	switch msg.Type {
	case "match":
		startMatch(p)
	case "play_card", "attack_minion", "attack_hero", "end_turn":
		forwardToRoom(p, msg)
	case "ping":
		send(p, "pong", nil)
	default:
		sendError(p, fmt.Sprintf("未知: %s", msg.Type))
	}
}

func send(p *Player, t string, payload interface{}) {
	p.Conn.WriteJSON(Msg{Type: t, Payload: json.RawMessage{}})
}

func sendError(p *Player, err string) {
	p.Conn.WriteJSON(Msg{Type: "error", Payload: json.RawMessage(fmt.Sprintf(`{"message":"%s"}`, err))})
}

// ===== 匹配 =====

func startMatch(p *Player) {
	queueMu.Lock()
	defer queueMu.Unlock()

	// 已在队列中
	for _, q := range queue {
		if q.ID == p.ID {
			return
		}
	}

	// 有对手
	if len(queue) > 0 {
		opponent := queue[0]
		queue = queue[1:]
		room := createRoom(opponent, p)
		notifyMatchReady(room)
		return
	}

	queue = append(queue, p)
	fmt.Printf("[队列] 玩家 %s 加入队列 (等待对手)\n", p.ID)
}

func createRoom(p1, p2 *Player) *Room {
	room := &Room{
		ID:       genID(),
		Player1: p1,
		Player2: p2,
	}
	p1.RoomID = room.ID
	p2.RoomID = room.ID
	rooms[room.ID] = room
	fmt.Printf("[房间] %s 创建: %s vs %s\n", room.ID, p1.ID, p2.ID)
	return room
}

func notifyMatchReady(r *Room) {
	r.mu.RLock()
	defer r.mu.RUnlock()

	r.Player1.Conn.WriteJSON(Msg{Type: "match_ready", Payload: json.RawMessage(fmt.Sprintf(`{"room_id":"%s","opponent":"%s"}`, r.ID, r.Player2.ID))})
	r.Player2.Conn.WriteJSON(Msg{Type: "match_ready", Payload: json.RawMessage(fmt.Sprintf(`{"room_id":"%s","opponent":"%s"}`, r.ID, r.Player1.ID))})

	fmt.Printf("[匹配] %s <-> %s 开始游戏\n", r.Player1.ID, r.Player2.ID)
}

func forwardToRoom(p *Player, msg Msg) {
	room, ok := rooms[p.RoomID]
	if !ok {
		sendError(p, "不在房间中")
		return
	}

	room.mu.RLock()
	defer room.mu.RUnlock()

	var target *Player
	if room.Player1.ID == p.ID {
		target = room.Player2
	} else if room.Player2.ID == p.ID {
		target = room.Player1
	} else {
		sendError(p, "不在此房间")
		return
	}

	if err := target.Conn.WriteJSON(msg); err != nil {
		fmt.Printf("[转发错误] %s\n", err)
	}
}

func removeFromQueue(p *Player) {
	queueMu.Lock()
	defer queueMu.Unlock()
	newQueue := make([]*Player, 0)
	for _, q := range queue {
		if q.ID != p.ID {
			newQueue = append(newQueue, q)
		}
	}
	queue = newQueue
}

func leaveRoom(p *Player) {
	if p.RoomID == "" {
		return
	}
	room, ok := rooms[p.RoomID]
	if !ok {
		return
	}

	room.mu.Lock()
	defer room.mu.Unlock()

	delete(rooms, p.RoomID)
	p.RoomID = ""

	if room.Player1 != nil && room.Player1.ID != p.ID {
		room.Player1.Conn.WriteJSON(Msg{Type: "opponent_disconnected"})
	} else if room.Player2 != nil && room.Player2.ID != p.ID {
		room.Player2.Conn.WriteJSON(Msg{Type: "opponent_disconnected"})
	}
}