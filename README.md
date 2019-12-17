# power_pem

To create a fully driven powershell scripts that generate PEM files

Specification can be found here. 
https://tools.ietf.org/html/rfc7468#appendix-B

##################################
# Some docs 
# Fully Powershell. 
# Doesnt requires any 3rd party libraries 
#################################

## Specs under PKCS#8
## Format definition : https://tools.ietf.org/html/rfc7468    ABNF
## 
## https://tools.ietf.org/html/rfc5958 - Page 3, Public Key format 
## PublicKey ::= BIT STRING
##   SEQUENCE 
##      -INTEGER (Modulus)
##      -INTEGER (Exponent)
## It uses hardcoded RSA object Id. If you're using other scheme, you have to update the rsaEncryptionOid
## Look at DER encoding https://tools.ietf.org/html/rfc8017#appendix-A.1.1
## for object ids RSA 
#################################

