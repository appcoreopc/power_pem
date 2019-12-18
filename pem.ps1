function FromBase64Url($base64Url) 
{
    if ($base64Url.Length % 4 -eq 0) 
    {
        $padded = $base64Url
    }
    else 
    {
        $padded = $base64Url + "====".Substring($base64Url.Length % 4)
    }
     
    $base64 = $padded.Replace("_", "/").Replace("-", "+")
    return [System.Convert]::FromBase64String($base64)
}


function EncodeIntegerBigEndian($stream, $value, $forceUnsigned)
{
    $stream.Write([byte]0x02)
    $prefixZeros = 0
    
    for ($i = 0; $i -lt $value.length; $i++)
    {
        if ($value[$i] -ne 0) 
        {
            break
        }

        $prefixZeros++
    }

    if ($value.Length - $prefixZeros -eq 0)
    {
        EncodeLength $stream 1
        $stream.Write([byte]0)
    }
    else
    {
        if ($forceUnsigned -and $value[$prefixZeros] -gt 0x7f)
        {
            EncodeLength $stream ($value.Length - $prefixZeros + 1)
            $stream.Write([byte]0);
        }
        else
        {
            EncodeLength $stream ($value.Length - $prefixZeros)
        }

        for ($i = $prefixZeros; $i -lt $value.Length; $i++)
        {
            $stream.Write($value[$i])
        }
    }
}

function EncodeLength($stream, $length)
{  
   if ($length -lt 0x80)
   {     
       $stream.Write([byte]$length)
   }
   else {
     $temp = $length
     $bytesRequired = 0

     while ($temp -gt 0)
     {
         $temp = $temp -shr 8;
         $bytesRequired++
     }

     $stream.Write([byte]($bytesRequired -bor 0x80))
     for ($i = $bytesRequired - 1; $i -ge 0; $i--)
     {
        $stream.Write([byte]($length -shr (8 * $i) -band 0xff));
     }
   }
}

function GeneratePublicKey($modulus, $exp)
{
        ### Start 
        $outputStream = New-Object System.IO.StringWriter

        $stream = New-Object System.IO.MemoryStream
        $writer  = New-Object System.IO.BinaryWriter($stream)

        $innerStream = New-Object System.IO.MemoryStream
        $innerWriter = New-Object System.IO.BinaryWriter($innerStream)

        $writer.Write([byte]0x30) ## SEQUENCE
      
            #### Inner Writer #####
            $innerWriter.Write([byte]0x30) ## SEQUENCE
            EncodeLength $innerWriter 13
            $innerWriter.Write([byte]0x06) ## OBJECT IDENTIFIER
            [byte[]] $rsaEncryptionOid = 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01

            EncodeLength $innerWriter $rsaEncryptionOid.length
            $innerWriter.Write($rsaEncryptionOid)
            $innerWriter.Write([byte]0x05) ## NULL
            EncodeLength $innerWriter 0
            $innerWriter.Write([byte]0x03) ## BIT STRING
            ####### Public key portion of things #######

            $bitStringStream = New-Object System.IO.MemoryStream
            $bitStringWriter = New-Object System.IO.BinaryWriter($bitStringStream)

            $bitStringWriter.Write([byte]0x00) ### of unused bits
            $bitStringWriter.Write([byte]0x30) ## SEQUENCE 

            $paramsStream = New-Object System.IO.MemoryStream
            $paramsWriter = New-Object System.IO.BinaryWriter($paramsStream)
        
                EncodeIntegerBigEndian $paramsWriter $modulus $True 
                EncodeIntegerBigEndian $paramsWriter $exp $True

            $paramsLength = $paramsStream.Length
            EncodeLength $bitStringWriter $paramsLength
            $bitStringWriter.Write($paramsStream.GetBuffer(), 0, $paramsLength)

            $bitStringLength = $bitStringStream.Length
            EncodeLength $innerWriter $bitStringLength
            $innerWriter.Write($bitStringStream.GetBuffer(), 0, $bitStringLength)

            #### Inner Writer ENDS ######

       
        $length = $innerStream.Length
        EncodeLength $writer $length
        $writer.Write($innerStream.GetBuffer(), 0, $length)

         #### Starting DER Generation ######

        $base64 = [System.Convert]::ToBase64String($stream.GetBuffer(), 0, $stream.length).ToCharArray()

        $outputStream.Write("-----BEGIN PUBLIC KEY-----")
        $outputStream.Write([System.Environment]::NewLine)
        for ($i = 0; $i -lt $base64.Length; $i += 64)
        {
            $next = [System.Math]::Min(64, $base64.Length - $i)
            $outputStream.Write($base64, $i, [System.Math]::Min(64, $base64.Length - $i))
            $outputStream.Write([System.Environment]::NewLine)
        }
        $outputStream.Write("-----END PUBLIC KEY-----")

        ####################################
        ### Write public key to console ####
        return $outputStream.ToString()
        ####################################
}

$modulus = FromBase64Url "your modulus value"
$exp = FromBase64Url "AQAB" ## Example of exponent, purposely hard coded here so user can differentiate different keys.

$pemPublicKey = GeneratePublicKey $modulus $exp
Write-Host($pemPublicKey)
