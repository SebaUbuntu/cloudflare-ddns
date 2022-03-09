# cloudflare-ddns

## Instructions

- Login to your Cloudflare account
- Note your zone name (which is your website name)
- Go to your website's DNS configuration section
- Create an A record (set whatever IP address) and note the name of it
- Go to your account settings
- Create a token with the following permissions and note your token:
  - zone / zone / read
  - zone / DNS / edit
  - limit to all zones from your account or all zones. specific zones are not enough.
- Clone this repo
- Copy example_keys.sh to keys.sh
- Edit keys.sh with your data
- Edit cloudflare-ddns.service with your folder location
- Copy cloudflare-ddns.service to /etc/systemd/system
- Run the following commands:

```sh
sudo systemctl enable cloudflare-ddns
sudo systemctl start cloudflare-ddns
```

The script will now run and update the IP address of the record every 10 minutes
