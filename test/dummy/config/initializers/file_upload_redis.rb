FileUpload::Engine.config.redis = Redis.new({
  host: "localhost",
  port: 6379,
  db: 7
})
