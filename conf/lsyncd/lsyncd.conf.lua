local mirror_host = os.getenv("MIRROR_HOSTNAME")
assert(mirror_host, "MIRROR_HOSTNAME env variable is not set")

local asset_path = os.getenv("ASSET_PATH")
assert(asset_path, "ASSET_PATH env variable is not set")

local storage_path = os.getenv("STORAGE_PATH")
assert(storage_path, "STORAGE_PATH env variable is not set")

local overlay_path = os.getenv("OVERLAY_PATH")
assert(overlay_path, "OVERLAY_PATH env variable is not set")

local fsi_config_path = os.getenv("FSI_CONFIG_PATH")
assert(fsi_config_path, "FSI_CONFIG_PATH env variable is not set")


settings {
  logfile = "/var/log/lsyncd.log",
  statusFile = "/var/log/lsyncd-status.log",
  statusInterval = 20,
  insist = true
}

sync {
  default.rsync,
  source = asset_path,
  target = mirror_host .. ":" .. asset_path,
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
  source = storage_path .. "/metadata",
  target = mirror_host .. ":" .. storage_path .. "/metadata",
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
  source = overlay_path,
  target = mirror_host .. ":" .. overlay_path,
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

--[[
sync {
  default.rsync,
  source = fsi_config_path,
  target = mirror_host .. ":" .. fsi_config_path,
  delay = 120,
  maxProcesses = 1,
  exclude = {'licence.xml'},
  rsync = {
    compress = false,
    archive = true,
    perms = true,
    owner = true,
    _extra = {"-a", "--itemize-changes", "--temp-dir=/tmp"},
    rsh = "ssh -q -p 22 -i /data/authorized_keys/sync.key -o StrictHostKeyChecking=no"
  }
}
--]]
