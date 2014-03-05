<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl" xmlns:capita="http://www.capita-software.co.uk/ABC/services/WSCTaxGetAccountDetails/">
  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />
  <xsl:variable name="description">For testing this outputs source XML</xsl:variable>

  <xsl:template match="/">
    <response>
      <title>Source Passthrough</title>
      <content>
        <xsl:copy-of select="."/>
      </content>
    </response>
  </xsl:template>
</xsl:stylesheet>
