#/bin/sh

#to use this script, get a GoDaddy Key and Auth Secret from https://developer.godaddy.com/keys/
#you will also need the console json parser "jq"
#and cURL

godaddy_key="GODADYYDSECRETKEY"
godaddy_auth="GODADDYAUTH"

dns_host='fw'
domain_name='contoso.org'

ct_header='Content-Type: application/json; charset=utf-8'
ac_header='Accept: application/json; charset=utf-8'
auth_header='Authorization: sso-key '$godaddy_key':'$godaddy_auth

#Determine MyIP
my_ip=`curl -s https://api.ipify.org/`
echo "My IP:$my_ip"

#pull all records example
#records_uri='https://api.godaddy.com/v1/domains/'$domain_name'/records'
#curl -v -X GET -H "$auth_header" -H "$ct_header" -H "$ac_header" "$records_uri"

#pull the target record from godaddy
#record is stored in a json array
record_by_name_uri='https://api.godaddy.com/v1/domains/'$domain_name'/records/A/'$dns_host
json_record=`curl -s -X GET -H "$auth_header" -H "$ct_header" -H "$ac_header" $record_by_name_uri`

current_record=`echo $json_record | jq -r '.[].data'`
echo "Current Registered IP:$current_record"

if [ "$current_record" != "$my_ip" ]
then
	echo "Updating to new IP Address"
	update_record_by_name_uri='https://api.godaddy.com/v1/domains/'$domain_name'/records/A/'$dns_host

	new_record='[{"data":"'$my_ip'","ttl":600}]'

	curl  -s  -X PUT -H "$auth_header" -H "$ct_header" -H "$ac_header" -d "$new_record" $update_record_by_name_uri
	logger Updating IP to:$my_ip
else
        echo "No IP change"
        logger No IP change
fi
