param(
    $context,
	$user_id
    )

$answer = @"
{
  "update": {
    "message": "Updated!"
  },
  "ephemeral_text": "You updated the post!"
}
"@ | ConvertFrom-Json

$answer.ephemeral_text= 'I recieve {0} from user_id={1}' -f $context, $user_id


return $($answer|ConvertTo-Json -Depth 100)