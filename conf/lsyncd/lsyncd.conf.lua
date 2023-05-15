settings {
  logfile = "/var/log/lsyncd.log",
  statusFile = "/var/log/lsyncd-status.log",
  statusInterval = 60,
  insist = true
}

sync {
  default.rsync,
  source = "/data/assets",
  target = "fsi-secondary.domain.tld:/opt/fsi-server-docker-v22/fsi-data/assets",
  delay = 120,
  maxProcesses = 1,
  rsync = {
    compress = false,
    archive = true,
    perms = true,
    owner = true,
    _extra = {"-a", "--itemize-changes", "--temp-dir=/tmp"},
    rsh = "ssh -q -p 22 -i /data/authorized_keys/sync.key -o StrictHostKeyChecking=no"
  }
}

sync {
  default.rsync,
  source = "/data/storage/metadata",
  target = "fsi-secondary.domain.tld:/opt/fsi-server-docker-v22/fsi-data/storage/metadata",
  delay = 120,
  maxProcesses = 1,
  rsync = {
    compress = false,
    archive = true,
    perms = true,
    owner = true,
    _extra = {"-a", "--itemize-changes", "--temp-dir=/tmp"},
    rsh = "ssh -q -p 22 -i /data/authorized_keys/sync.key -o StrictHostKeyChecking=no"
  }
}

sync {
  default.rsync,
  source = "/data/overlay",
  target = "fsi-secondary.domain.tld:/opt/fsi-server-docker-v22/fsi-data/overlay",
  delay = 120,
  maxProcesses = 1,
  rsync = {
    compress = false,
    archive = true,
    perms = true,
    owner = true,
    _extra = {"-a", "--itemize-changes", "--temp-dir=/tmp"},
    rsh = "ssh -q -p 22 -i /data/authorized_keys/sync.key -o StrictHostKeyChecking=no"
  }
}

# sync {
#   default.rsync,
#   source = "/data/config",
#   target = "fsi-secondary.domain.tld:/opt/fsi-server-docker-v22/config",
#   delay = 120,
#   maxProcesses = 1,
#   exclude = {'licence.xml'},
#   rsync = {
#     compress = false,
#     archive = true,
#     perms = true,
#     owner = true,
#     _extra = {"-a", "--itemize-changes", "--temp-dir=/tmp"},
#     rsh = "ssh -q -p 22 -i /data/authorized_keys/sync.key -o StrictHostKeyChecking=no"
#   }
# }
