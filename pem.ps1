function ByteMyString($stringValue)
{
  $bytesValue = [System.Text.Encoding]::Unicode.GetBytes($stringValue)
  $EncodedText =[Convert]::ToBase64String($bytesValue)
  return $EncodedText
}

function ToByte($stringValue)
{
  $bytesValue = [System.Text.Encoding]::Unicode.GetBytes($stringValue)
  return $bytesValue
}

function EncodeLength($stream, $length)
{
   Write-Host($length)
   Write-Host($stream)

   if ($length -lt 0x80)
   {     
       $stream.Write([byte[]]$length)
   }
   else {

     $temp = $length
     $bytesRequired = 0

     while ($temp > 0)
     {
         $temp -shr 8;
         $bytesRequired++
     }

     $stream.Write([byte[]]$bytesRequired -bor 0x80)
     #$stream.Write([byte[]]$bytesRequired)
     for ($i = $bytesRequired - 1; $i -ge 0; $i--)
      {
         $stream.Write([byte[]]($length -shr (8 * $i) -band 0xff));
      }
   }
}

function EncodeIntegerBigEndian($stream, $value, $sign)
{                
    $stream.Write(0x02)
}

$m = New-Object System.IO.MemoryStream
$mbw = New-Object System.IO.BinaryWriter($m)

$cm = New-Object System.IO.MemoryStream
$cbw = New-Object System.IO.BinaryWriter($cm)

$mbw.Write(0x30) ## SEQUENCE

EncodeLength $cbw 13

$mbw.Write(0x06) ## Identifier

$rsaEncryptionOid = 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01

#EncodeLength($bw, 9)

