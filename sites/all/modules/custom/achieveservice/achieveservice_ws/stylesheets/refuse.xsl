<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:msxsl="urn:schemas-microsoft-com:xslt" exclude-result-prefixes="msxsl" xmlns:capita="http://www.capita-software.co.uk/ABC/services/WSCTaxGetAccountDetails/">
	<xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:output method="xml" indent="yes" omit-xml-declaration="yes" />
  <xsl:variable name="description">Refuse information</xsl:variable>

  <xsl:template match="/">
    <response>
      <title></title>
      <content>
	      <div class="links">
		    <!--Output non-internal form links -->
	        <xsl:for-each select="//links/link[(not(@rel) or @rel!='internal') and @type='form']">
	          <xsl:apply-templates select="." />
	        </xsl:for-each>
	      </div>
      </content>
    </response>
  </xsl:template>
	
  <xsl:template match="link[@type='form']">
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="php:function('base_path')" />default.aspx/<xsl:value-of select="@href" />&amp;FinishURL=/../<xsl:value-of select="$return_path" />
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:value-of select="@title" />
      </xsl:attribute>
      <xsl:value-of select="@title" />
    </a>
  </xsl:template>

</xsl:stylesheet>
