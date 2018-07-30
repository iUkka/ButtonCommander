param(
    [string]$user_name
)

$answer = @"
{
            'response_type': 'in_channel',
            'attachments': [{
                'text': "text",
                'actions': [{
                    'name': 'Vote Yes',
                    'integration': {
                        'url': "http://192.168.0.1:12345/testbuttonanswer",
                        'context': {
                            'poll_id': 11,
                            'vote': 'Yes'
                        }
                    }
                }, {
                    'name': 'Vote No',
                    'integration': {
                        'url': "http://192.168.0.1:12345/testbuttonanswer",
                        'context': {
                            'poll_id': 12,
                            'vote': 'No'
                        }
                    }
                }, {
                    'name': 'End Poll',
                    'integration': {
                        'url': "http://192.168.0.1:12345/testbuttonanswer",
                        'context': {
                            'poll_id': 13,
                            'prompt': "End poll"
                        }
                    }
                }]
            }]
        }
"@ | ConvertFrom-Json

return ($answer|Convertto-Json -Compress -Depth 100)
