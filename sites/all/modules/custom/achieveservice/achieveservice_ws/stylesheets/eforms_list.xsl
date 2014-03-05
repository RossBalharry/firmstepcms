<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" version="1.0">
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">eForms list with links</xsl:variable>

  <xsl:template match="/feed">
    <response>
      <title><h1 id="eforms-header">eForms</h1></title>
      <content>
        <ul class="forms-list">
          <xsl:apply-templates select="entry" />
        </ul>
      </content>
    </response>
  </xsl:template>

  <xsl:template match="entry">
    <li>
      <a>
        <xsl:attribute name="href">
          <xsl:value-of select="php:function('base_path')" />default.aspx/Home/Home/ServiceRequest/?sid=<xsl:value-of select="short_name" />&amp;FinishURL=/../services
        </xsl:attribute>
        <xsl:value-of select="name" />
      </a>
      <span class="description">
        <xsl:value-of select="description" />
      </span>
    </li>
  </xsl:template>
</xsl:stylesheet>
