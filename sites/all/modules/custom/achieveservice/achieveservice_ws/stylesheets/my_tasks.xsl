<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
  <xsl:param name="scope" />
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">My Cases</xsl:variable>
  <xsl:variable name="cases_path">firmstep/selfservice/accounts/cases</xsl:variable>

  <xsl:template match="/">
    <response>
      <title></title>
      <content>
        <xsl:choose>
          <xsl:when test="count(/feed/entry) = 0">
            <xsl:call-template name="no-cases" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="/feed/entry">
              <xsl:call-template name="case" />
            </xsl:for-each>
            <xsl:call-template name="cases-footer" />
          </xsl:otherwise>
        </xsl:choose>
      </content>
    </response>
  </xsl:template>
  
  <xsl:template name="no-cases">
    (You currently do not have any cases.)
  </xsl:template>

  <xsl:template name="cases-footer">
    <xsl:choose>
      <xsl:when test='$scope = "my_cases"'>
      </xsl:when>
      <xsl:otherwise>
        <div class="mycases-footer">
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="concat(php:function('base_path'), $cases_path)" />
            </xsl:attribute>
            All Cases
          </a>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="case">
    <div class='my-case'>
     <div class='links'>
        <!--<xsl:if test="string(has_external_viewdata_url) = 'yes'">
         <a href="{external_viewdata_url}">External View Data</a>
        </xsl:if> -->
  
        <a><xsl:attribute name="href"><xsl:value-of select="viewurl"/></xsl:attribute>View</a>
      </div>

      <div class='my-case-details'>
        <span class='label'>Case Type: </span><xsl:value-of select="formname"/>
      </div>
      <div class='my-case-details'>
        <span class='label'>Reference: </span><xsl:value-of select="reference"/>
      </div>
      <div class='my-case-details'>
        <span class='label'>Current Status: </span><xsl:value-of select="status"/>
      </div>
      <div class='my-case-details'>
        <span class='label'>Created: </span><xsl:value-of select="datecreatedpretty"/>
      </div>
    </div>
    <div class='clear'></div>
  </xsl:template>
  
</xsl:stylesheet>
