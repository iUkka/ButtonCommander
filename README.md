# ButtonCommander

### Disclaimer:
Script was written for Mattermost v4.8, but may work on other version.  
Script was written for PS v.3.0 (For Windows Server 2008 Std) but still work on PS 5.1 

## Description
Это сервис для [Mattermost](http://www.mattermost.org/), написан удобства запуска различных powershell скриптов из slash/custom команд.  
Для запуска необходимо два условия:  
  * перед пользованием скрипта необходимо переименовать settings.ini.example в settings.ini и внести в него необходимые Вам изменения.
  * у пользователя должно быть право на чтение и запуск скриптов, описанных в ini файле
  * у пользователя должно быть право на создание сокета.
  
Краткое описание:  
###### settings.ini
INI файл для управления работы скриптов, должен называться setting.ini и находится в папке со скриптом, либо быть указан другой ini файл через параметры. 
```
.\ButtonCommander.ps1 -Config C:\Users\akorolev\Other\myini.ini
```
Формат INI файла описан в example файле.

###### ButtonCommander.ps1
Запускать сервис можно из командной строки ( с ключем -Verbose удобно для поиска проблем), шедуллером, сервисом и вообще как только удобно.

Ключи запуска:
```
-ListenerPort [Default:12345]
-ListenerHost [Default:+]
-Config [Default:$PSScriptRoot\settings.ini]
-Verbose [Default:$false]
```

Сервис получает данные со скриптов, полученные через return или write-output и посылает их в channel, из которого пришел запрос.
Если данные пришли в форме JSON, то конвертация не происходит, а в [Mattermost](http://www.mattermost.org/) посылается исходный JSON.  
Примеры:  
Секция [script] возвращает строковые данные, которые конвертируются в JSON уже сервисом. Получается простое текстовое сообщение.  Секция [testhell] формирует собственный JSON, который без изменений проходит в [Mattermost](http://www.mattermost.org/) и показывает формы с кнопками, которые, в свою очередь обрабатываюся в секции [testbuttonanswer]  

**Внимание:** Форматирование сообщений и/или формирование JSON файлика - целиком заслуга клиента :)  
Включайте Verbose mode и тестируйте свои сообщения.  
**Например, тестирование поведения сервиса при обработке секции [script]:**
```
PS C:\ButtonCommander> $1 = .\Dummy-Script.ps1
PS C:\ButtonCommander> (Invoke-WebRequest -Method Post -uri "http://localhost:12345/script" -body $1).Rawcontent
HTTP/1.1 200 OK
Content-Length: 117
Content-Type: application/json
Date: Mon, 30 Jul 2018 12:11:27 GMT
Server: Microsoft-HTTPAPI/2.0

{
    "response_type":  "in_channel",
    "text":  "You passed 0 arguments:\r\nNamed param  team_domain is \r\n"
}
```
Так как запрос был сделан локально, то text, team_domain, user_name не передались, это нормально. За исключением этого все отработало штатно, на выход получен ответ без ошибок.

### Prerequests:
1) Внесите в config-файл [Mattermost](http://www.mattermost.org/) в секцию "AllowedUntrustedInternalConnections" IP сервера, на котором будет работать данный скрипт. Далее все упоминания про ip будут именно про этот ip.
2) Удостоверьтесь, сервис доступен с удаленной машины (Файервол)
3) Внесите изменения в скрипт Dummy-TestHello.ps1  
Замените адрес 192.168.0.1 на на ваш IP.
4) Создайте вебхуки script и test как на картинке.  
<img src="https://user-images.githubusercontent.com/5823637/43399433-ac6a53c2-9413-11e8-91b4-12b3cd1dda6d.png" alt="" width="200" /> <img src="https://user-images.githubusercontent.com/5823637/43399471-d459c58e-9413-11e8-9471-209d3ac71c5f.png" alt="" width="200" />
5) Из любого канала [Mattermost](http://www.mattermost.org/) вызвайте /script или /test (можно с параметрами, скриптах группы [script] Обрабатываются аргументы. 
 
### Known issues:
Если вы получаете ошибку 
**Команда с триггером 'test' завершилась с ошибкой**  
то у вас скорее всего в логах [Mattermost](http://www.mattermost.org/) есть строки с надписью
```
[EROR] /api/v4/commands/execute:command code=500 rid= uid= ip=192.168.0.1 Command with a trigger of 'test' failed [details: Post http://192.168.0.1:12345/script: address forbidden]
```
Решение: Прописать используемый ip в конфиг [Mattermost](http://www.mattermost.org/) в секцию "AllowedUntrustedInternalConnections"

**No text specified**
Если вы получаете на вроде как рабочий JSON ответ **No text specified** то это более комплексная проблема. Я попытался обойти ее в скрипте, и это частично получилось. Тут проблема в несоответствии перевода строки между Windows и Linux системами, помноженное на какие-то внутренние микропроблемы. Более глубоко я не копал.  
**_Старайтесь избегать виндовых переводов строк в ответе скриптов_**, там где есть возможность перевдите ответ одной строкой с форматированием, передавайте ответы с помощью Write-Output, конвертируйте в тип String.  

###Features:
У сервиса есть два бага, которые определены в фичи. 
1) Так как просто убить рабочий сокет тяжело, неудобно и неправильно, была сделана фича для остановки сервиса. Для остановки сервиса достаточно послать запрос на сокет с адресом, заканчивающимся на stop. Это самый корректный и верный способ остановки сервиса!  
Например:
```
Invoke-RestMethod -Method get -Uri "http://localhost:12345/stop"
```
2) После изменения конфиг-файла вместо рестарта сервиса можно заставить сервис перечитать его на лету.
Для этого нужно послать запрос на сокет с адресом, заканчивающимся на reload.  
Например:  
```
Invoke-RestMethod -Method get -Uri "http://localhost:12345/reload"
```


