const { exec } = require('child_process');
const http = require('http');

// 简单健康检查脚本
const PORT = process.env.PORT || 8080;

http.get(`http://localhost:${PORT}/health`, (res) => {
  if (res.statusCode === 200) {
    process.exit(0);
  } else {
    process.exit(1);
  }
}).on('error', () => process.exit(1));
