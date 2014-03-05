<?php

class FAM {
  private $key;
  private $iv;
  private $cipher;

  public function __construct($fam_key, $fam_iv, $fam_cipher) {
    //PHP's AES encryption is actually done using rijndael, but there's one small issue in that rijndael-256
    //wants a 32bit IV and our platform AES stuff uses a 16bit IV
    //The workaround is to use rijndael-128 but provide it with a 32bit key, so it knows to use -256
    //but won't complain about the IV being too short.  (Please kill me now!)
    $cipher_map = Array("AES" => MCRYPT_RIJNDAEL_128, "RC2" => MCRYPT_RC2);

    $this->key = $fam_key;
    $this->iv = $fam_iv;
    $this->cipher = $cipher_map[$fam_cipher];
    if ($this->cipher == NULL) {
      throw new Exception('Unsupported cipher ' . $fam_cipher);
    }
  }

  public function generate_request() {
    return $this->encode($this->generate_saml());
  }

  public function decode_response($auth_token) {
    return $this->load_saml($this->decode($auth_token));
  }


  private function generate_saml() {
    $saml = '<AuthnRequest xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" ID="';
    $saml .= uniqid('', TRUE);
    $saml .= '" Version="2.0" IssueInstant="';
    $saml .= date("c");
    $saml .= '" AttributeConsumingServiceIndex="0" xmlns="urn:oasis:names:tc:SAML:2.0:protocol"><Issuer xmlns="urn:oasis:names:tc:SAML:2.0:assertion">http://famdemo.itechcraft</Issuer><Extensions /><Subject xmlns="urn:oasis:names:tc:SAML:2.0:assertion" /><NameIDPolicy /><Conditions NotOnOrAfter="';
    $saml .= date("c", time() + 120);
    $saml .= '" xmlns="urn:oasis:names:tc:SAML:2.0:assertion" /><RequestedAuthnContext /><Scoping><IDPList /></Scoping></AuthnRequest>';

    return $saml;
  }

  private function load_saml($document) {

    $saml = new DOMDocument();
    $saml->loadXML($document);
    $saml_xpath = new DOMXPath($saml);
    $saml_xpath->registerNamespace("saml", "urn:oasis:names:tc:SAML:2.0:protocol");
    $saml_xpath->registerNamespace("samlassertion", "urn:oasis:names:tc:SAML:2.0:assertion");

    //first, check for a valid response
    $status = $saml_xpath->query("/saml:Response/saml:Status/saml:StatusCode");
    if ($status->length == 0) {
      throw new Exception('FAM response status not found.');
    }
    $status_value = $status->item(0)->attributes->getNamedItem("Value");
    if ($status_value == NULL || $status_value->textContent != "urn:oasis:names:tc:SAML:2.0:status:Success") {
      throw new Exception('FAM response status failed.');
    }

    //next, check the timestamps.  We allow +- 10 mins on this (this is to prevent replay attacks)
    $time_stamp = $saml_xpath->query("/saml:Response/samlassertion:Assertion/samlassertion:AuthnStatement");
    if ($time_stamp->length == 0) {
      throw new Exception('FAM response timestamp not found.');
    }
    $time_stamp_value = $time_stamp->item(0)->attributes->getNamedItem("AuthnInstant");
    $time_stamp_time = new DateTime($time_stamp_value->textContent);
    $current_time = new DateTime();
    if ($time_stamp_value == NULL || abs($time_stamp_time->getTimestamp() - $current_time->getTimestamp()) > 600) {
      throw new Exception('FAM response timestamp is too old.  Check clocks on both servers.');
    }

    //ok, now loop through each supplied attribute and build up an array object to return
    $result = Array();
    $attributes = $saml_xpath->query("/saml:Response/samlassertion:Assertion/samlassertion:AttributeStatement/samlassertion:Attribute");

    foreach ($attributes as $attribute) {
      $friendly_name = $attribute->attributes->getNamedItem("FriendlyName")->textContent;

      if ($attribute->hasChildNodes()) {
        foreach ($attribute->childNodes as $childnode) {
          if ($childnode->nodeName == "AttributeValue") {
            if (isset($result[$friendly_name])) {
              //we've already set this attribute
              //check if it's an array or single value
              if (is_array($result[$friendly_name])) {
                //we've already got an array for this attribute, so add to the array
                array_push($result[$friendly_name], $childnode->textContent);
              }
              else {
                //replace the existing single value with an array of the old value and the new one
                $result[$friendly_name] = Array($result[$friendly_name], $childnode->textContent);
              }
            }
            else {
              //single attribute value
              $result[$friendly_name] = $childnode->textContent;
            }
          }
        }
      }
    }
    return $result;
  }

  private function encode($plain_text) {
    //append 4 bytes to the beginning of the string specifying the length
    $length = strlen($plain_text);
    $raw_string = sprintf("%c%c%c%c" . $plain_text, ($length & 0x000000FF), ($length & 0x0000FF00) >> 8, ($length & 0x00FF0000) >> 16, ($length & 0xFF000000) >> 24);

    //URGH - PHP mcrypt does't support PKCS5/PKCS7 padding so we have to add this ourselves
    //Most encryption ciphers require you to pad the plaintext data to be a length of the blocksize
    //Normally this is done by adding null bytes to the end of the string (which is what mcrypt will do)
    //PKCS padding requires that extra bytes are added to the end of the data, with the value
    //of each byte being the number of bytes added.  (So, add two bytes with values 0x02 or add
    //7 bytes with values 0x07 etc.)  If the data is already an exact multiple of the blocksize,
    //then you have to add another whole blocksize length of padding
    $block_size = mcrypt_get_block_size($this->cipher, MCRYPT_MODE_CBC);
    $pad_length = $block_size - (strlen($raw_string) % $block_size);
    $raw_string .= str_repeat(chr($pad_length), $pad_length);

    //do the encryption
    $td = mcrypt_module_open($this->cipher, "", MCRYPT_MODE_CBC, "");
    mcrypt_generic_init($td, base64_decode($this->key), base64_decode($this->iv));
    $encrypted = mcrypt_generic($td, $raw_string);
    mcrypt_generic_deinit($td);
    mcrypt_module_close($td);

    //finally, base64 encode and then html encode the result
    $encrypted_base64 = base64_encode($encrypted);
    $final_result = htmlspecialchars($encrypted_base64);

    return $final_result;

  }

  private function decode($cipher_text) {
    //OK, apply the reverse operations from the encode() function in reverse order:

    $encrypted_base64 = base64_decode($cipher_text);

    //do the decryption
    $td = mcrypt_module_open($this->cipher, "", MCRYPT_MODE_CBC, "");
    mcrypt_generic_init($td, base64_decode($this->key), base64_decode($this->iv));
    $raw_string = mdecrypt_generic($td, $encrypted_base64);
    mcrypt_generic_deinit($td);
    mcrypt_module_close($td);

    //strip string length off the beginning
    $length_1 = ord(substr($raw_string, 0, 1));
    $length_2 = ord(substr($raw_string, 1, 1));
    $length_3 = ord(substr($raw_string, 2, 1));
    $length_4 = ord(substr($raw_string, 3, 1));
    $length = $length_1 + ($length_2 << 8) + ($length_3 << 16) + ($length_4 << 24);
    $raw_string = substr($raw_string, 4);

    //now, remove the PKCS padding which mcrypt doesn't understand
    $pad_length = ord(substr($raw_string, -1));
    $plain_text = substr($raw_string, 0, strlen($raw_string) - $pad_length);

    //sanity check on string length
    if (strlen($plain_text) != $length) {
      throw new Exception('String length does not match received data.');
    }

    return $plain_text;
  }
}
