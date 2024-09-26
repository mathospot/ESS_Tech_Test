node default {
  case $facts['os']['name'] {
    'Ubuntu': {
      include ubuntu
    }
    'Darwin': {
      include macos
    }
    'Windows': {
      include windows
    }
    default: {
      fail("Unsupported operating system: ${facts['os']['name']}")
    }
  }
}
