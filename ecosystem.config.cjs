module.exports = {
  apps: [
    {
      name: "backend-api",
      cwd: "./apps/api",
      script: "dist/index.js",
      env: {
        NODE_ENV: "production"
      }
    }
  ]
};