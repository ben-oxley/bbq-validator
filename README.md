Run terraform with `terraform plan -var-file="config.tfvars"`

## SES Domain Validation 

;; CNAME Records
5ajq32ythaxst25ygy7iptizh57kcqrf._domainkey.bbq.benoxley.com.	1	IN	CNAME	5ajq32ythaxst25ygy7iptizh57kcqrf.dkim.amazonses.com.
gjoe25jhnggfwhuoug6ckoudjtqglnzj._domainkey.bbq.benoxley.com.	1	IN	CNAME	gjoe25jhnggfwhuoug6ckoudjtqglnzj.dkim.amazonses.com.
zquk5cyniunm5ncuv2jlznispfo2qfx4._domainkey.bbq.benoxley.com.	1	IN	CNAME	zquk5cyniunm5ncuv2jlznispfo2qfx4.dkim.amazonses.com.



## Setting email email receipt

https://docs.aws.amazon.com/ses/latest/dg/receiving-email-setting-up.html

;; MX Records
bbq.benoxley.com.	1	IN	MX	10 inbound-smtp.eu-west-2.amazonaws.com.

## Leaderboard

Leaderboard is at:

[http://bbq.benoxley.com.s3-website-eu-west-1.amazonaws.com/](http://bbq.benoxley.com.s3-website-eu-west-1.amazonaws.com/)