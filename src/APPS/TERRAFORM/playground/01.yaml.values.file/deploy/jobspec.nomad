job "myawesomejob2" {
  datacenters = ["dc1","dc2","dc3"]
  type = "service"

  group "myawesomejob2" {
    count = 2

    task "frontend" {
      driver = "docker"
      config {
        image = myawesomejob:1.0.1
      }
    }
  }
}
