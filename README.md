# ButtonCommander

## Table of Contents

- [Описание на русском после описания на английском](#russian)
- [Disclaimer](#disclaimer)
- [Prerequests](#prerequests)
- [Known issues](#issues)
- [Features](#features)

I am sorry, my english is not native language, but i still try to learn it.

## Disclaimer
Script was written for Mattermost v4.8, but may work on other version.  
Script was written for PowerShell v.3.0 (For Windows Server 2008 Std) but still works on PowerShell 5.1 

## Description
This backend for [Mattermost](http://www.mattermost.org/) was written for the convenience of running various powershell scripts from slash/custom commands.
product example, not included to source:  
![buttoncommanderwho](https://user-images.githubusercontent.com/5823637/43575686-1d451b3e-9650-11e8-8926-8ccb4bfb3390.gif)


###### settings.ini
INI file to control operation of the script has to be in the setting.ini and is located in the folder with the script, or be specified another ini file through the parameters. 
```
.\ButtonCommander.ps1 -Config C:\Users\akorolev\Other\myini.ini
```
The format of the INI file is described in the example file.

###### ButtonCommander.ps1
You can start the service from the command line (with the-Verbose key it is convenient to find problems), the scheduler, the service and in General as soon as it is convenient.

Startup keys:
```
-ListenerPort [Default:12345]
-ListenerHost [Default:+]
-Config [Default:$PSScriptRoot\settings.ini]
-Verbose [Default:$false]
```

The service receives data from scripts received via return or write-output and sends it to the channel from which the request came.
If the data came in the form of JSON, the conversion does not occur, and in 
ermost](http://www.mattermost.org/) the source JSON is sent.  
Examples:  
The [script] section returns string data that is converted to JSON by the service. It turns out a simple text message.  
Section [testhello] generates JSON which no change takes place in the [Mattermost](http://www.mattermost.org/) and shows forms with buttons, which in turn are processed in the [testbuttonanswer] section

** Attention: ** Formatting of messages and / or creating JSON file is entirely the merit of the user :)  
Enable Verbose mode and test your messages.  
**For example, testing the service behavior when processing the [script] section:**
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
Since the request was made locally (not from Mattermost, just pure powershell), variables text, team_domain, user_name were not passed. Except that, everything worked normally, the output response is received without error.

### Prerequests
1) Make the config file [Mattermost](http://www.mattermost.org/) in section "AllowedUntrustedInternalConnections" IP of the server that will run this script. Next, all the mention about the IP will be about this one.
2) Make sure the service is available from the remote machine (Firewall)
3) make changes to the Dummy-TestHello script.ps1
Change ip 192.168.0.1 to your ip.
4) Run script .\ButtonCommander.ps1 (or .\ButtonCommander.ps1 -Verbose), but be sure about two things:
  * the current user must have the right to read and run the scripts described in the ini file.
  * the current user must have the right to create a socket.
5) Create webhook script and test just like the picture.  
<img src="https://user-images.githubusercontent.com/5823637/43399433-ac6a53c2-9413-11e8-91b4-12b3cd1dda6d.png" alt="" width="200" /> <img src="https://user-images.githubusercontent.com/5823637/43399471-d459c58e-9413-11e8-9471-209d3ac71c5f.png" alt="" width="200" />
5) From any channel [Mattermost](http://www.mattermost.org/) run /script or /test (you can use with parameters, on command [script] you may recieve some arguments.)
 
### Issues
If you get an error 
**Command with 'test' trigger failed**  
Check your logs in [Mattermost](http://www.mattermost.org/)
```
[EROR] /api/v4/commands/execute:command code=500 rid= uid= ip=192.168.0.1 Command with a trigger of 'test' failed [details: Post http://192.168.0.1:12345/script: address forbidden]
```
Check https://github.com/iUkka/ButtonCommander/README.md#Prerequests item one. 

**No text specified**
If you get on a sort of working JSON response to **No text specified** then this is a more complex problem. I tried to bypass it in the script and it partially worked. The problem here is the mismatch of line translation between Windows and Linux systems, multiplied by some internal micro-problems. I didn't dig any deeper.  
**_On multiline texts try to avoid the newline in the response_**, put the answer in one line with the formatting, use Write-Output or convert it to a String. Use magic!

## Features
1) Since just killing a working socket is hard, inconvenient and wrong, a feature was made to stop the service. To stop the service, it is enough to send a request for a socket with an address ending with stop. This is the most correct and correct way to stop the service!  
For example:
```
Invoke-RestMethod -Method get -Uri "http://localhost:12345/stop"
```
2) After changing the config file, you can make the service re-read it on the fly instead of restarting the service.
To do this, send a request to a socket with an address ending in reload.  
For example:
```
Invoke-RestMethod -Method get -Uri "http://localhost:12345/reload"
```
-------------

# Russian

## Описание
Это сервис для [Mattermost](http://www.mattermost.org/), написан удобства запуска различных powershell скриптов из slash/custom команд.  
  
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

### Подготовка
  * перед пользованием скрипта необходимо переименовать settings.ini.example в settings.ini
  * у пользователя должно быть право на чтение и запуск скриптов, описанных в ini файле
  * у пользователя должно быть право на создание сокета.

1) Внесите в config-файл [Mattermost](http://www.mattermost.org/) в секцию "AllowedUntrustedInternalConnections" IP сервера, на котором будет работать данный скрипт. Далее все упоминания про ip будут именно про этот ip.
2) Удостоверьтесь, сервис доступен с удаленной машины (Файервол)
3) Внесите изменения в скрипт Dummy-TestHello.ps1  
Замените адрес 192.168.0.1 на на ваш IP.
4) Создайте вебхуки script и test как на картинке.  
<img src="https://user-images.githubusercontent.com/5823637/43399433-ac6a53c2-9413-11e8-91b4-12b3cd1dda6d.png" alt="" width="200" /> <img src="https://user-images.githubusercontent.com/5823637/43399471-d459c58e-9413-11e8-9471-209d3ac71c5f.png" alt="" width="200" />
5) Из любого канала [Mattermost](http://www.mattermost.org/) вызвайте /script или /test (можно с параметрами, в скриптах группы [script] обрабатываются аргументы.)
 
### Известные ошибки
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

###Фичи
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


