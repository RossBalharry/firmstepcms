<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
  <xsl:param name="return_path"/>
  <xsl:param name="uid" />
  <xsl:param name="scope" />
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">My Tasks</xsl:variable>
  
  <xsl:variable name="cases_path">firmstep/selfservice/accounts/cases</xsl:variable>

  <xsl:template match="/">
    <response>
      <title></title>
      <content>
        <xsl:choose>
          <xsl:when test="count(/feed/entry) = 0">
            <xsl:call-template name="no-tasks"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="/feed/entry">
              <xsl:call-template name="task"/>
            </xsl:for-each>  
            <xsl:call-template name="tasks-footer"/>
          </xsl:otherwise>
        </xsl:choose>
      </content>
    </response>
  </xsl:template>
  
  <xsl:template name="no-tasks">
    (You do not have any tasks in progress.)
  </xsl:template>
  
  <xsl:template name="tasks-footer">
    <xsl:choose>
      <xsl:when test='$scope = "my_tasks"'>
      </xsl:when>
      <xsl:otherwise>
        <div class="mytasks-footer">
          <a>
            <xsl:attribute name="href">
              <xsl:value-of select="concat(php:function('base_path'), $cases_path)" />
            </xsl:attribute>
            All Tasks
          </a>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="task">
    <div class="my-case">
      <div class="links">
        <a href="{actionurl}&amp;ReturnURL=/../{$return_path}&amp;AFSkipExtraPage=1&amp;HideToolbar=1">Continue</a>
      </div>
      <xsl:choose>
        <xsl:when test="string(stagename) != ''">
          <div class='my-case-details'>
            <span class='label'>Case Type: </span><xsl:value-of select="processname"/>
          </div>
          <div class='my-case-details'>
            <span class='label'>Case Stage: </span><xsl:value-of select="stagename"/>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <div class='my-case-details'>
            <span class='label'>Case Type: </span><xsl:value-of select="formname"/>
          </div>
        </xsl:otherwise>
      </xsl:choose>
      <div class='my-case-details'>
        <span class='label'>Status: </span><xsl:value-of select="status"/>
      </div>
      <div class='my-case-details'>
        <span class='label'>Reference: </span><xsl:value-of select="reference"/>
      </div>
      <div class='my-case-details'>
        <span class='label'>Created: </span><xsl:value-of select="datecreatedpretty"/>
      </div>
    </div>
    <div class='clear'></div>
  </xsl:template>
  
  <!--
  <threadcreator>Anonymous User</threadcreator>
	<processid>1107</processid>
	<reference>FBK118194</reference>
	<status_id>2</status_id>
	<actionurl>/default.aspx/Stages/RenderProcess/?TaskID=23966</actionurl>
	<allowbulkfill>0</allowbulkfill>
	<formname>Feedback - Response</formname>
	<stagename>Response</stagename>
	<datecreated>2011-02-02 15:31:29.937000+0000</datecreated>
	<task_due_datetime>2011-02-23 15:29:30.330000+0000</task_due_datetime>
	<created_by_operator>AnonymousUs</created_by_operator>
	<processname>Feedback</processname>
	<published>Published</published>
	<taskid>23966</taskid>
	<stageid>3129</stageid>
	<status>In progress</status>
	<threadid>19226</threadid>
	<datecreatedpretty>8 days ago</datecreatedpretty>
  -->
  
</xsl:stylesheet>
