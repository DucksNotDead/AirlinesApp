## Setup

``/Services/ApiService.swift``
```
Выбрать хост где запускается API

...
enum Hosts: String {
	case local = "localhost" //эмулятор
	case home = "192.168.0.101"
}

let HOST: Hosts = .local
...
```


