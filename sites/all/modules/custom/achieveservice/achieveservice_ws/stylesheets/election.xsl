<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
	<xsl:param name="return_path" />
	<xsl:param name="uid" />
	<xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
	<xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/map.xsl" />
	<xsl:variable name="description">Election Information</xsl:variable>

	<xsl:template match="/">
		<response>
			<title>Election Information</title>
			<content>
				<xsl:choose>
					<xsl:when test="count(/feed/ServicesResponseEnvelope/XpressElections/ElectoralNumber) = 0">
						<xsl:call-template name="no-election-detail" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="feed/ServicesResponseEnvelope/XpressElections" />
						<xsl:choose>
							<xsl:when test="count(/feed/ServicesResponseEnvelope/XpressElections/Election) = 0">
								<div class='election-message'>You are registered to vote for elections, however there are no upcoming elections.</div>
							</xsl:when>
							<xsl:otherwise>
								<div class='election-message'>You are registered to vote for the elections below.</div>
								<xsl:apply-templates select="feed/ServicesResponseEnvelope/XpressElections/Election" />
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
				</xsl:choose>
			        <div class='clear'></div>
			        <div class="global-links">
			          <xsl:apply-templates select="//links/link[(not(@rel) or @rel!='internal') and (@type='form' or @type='external')]"/>
			        </div>
			</content>
		</response>
	</xsl:template>


	<xsl:template match="XpressElections">
			<div class='left'><span><b>Electoral number: </b> </span><span><xsl:value-of select="ElectoralNumber" /></span></div>
			<div class='clear'> </div>
	</xsl:template>

	<xsl:template match="Election">
		<xsl:call-template name="expandable">
			<xsl:with-param name="title" select="ElectionTitle"/>
			<xsl:with-param name="expanded" select="true()"/>
			<xsl:with-param name="body">
				<style>
					.election .election-info { width: 55%; }
					.map-frame { width: 350px; height: 200px; } 
				</style>
				<div class="election">
					<div class="election-info left">
						<div><b class='highlight'>
							Polling day: <xsl:value-of select="PollingDate" />
						</b></div>
						<div><b class='highlight'>
							Polling hours: <xsl:value-of select="PollingStartEnd" />
						</b></div>
						<div class='clear'> </div>
						<div class='left '>
							<b>Type of election: </b> <xsl:value-of select="ContestType" />
						</div>
						<div class='left'>
							<b>Area: </b> <xsl:value-of select="ContestArea" />
						</div>
							<div class='clear'> </div>
						<div>
							<b>Polling station: </b> 
							<xsl:value-of select="PollingStation/PollingStationName" />, 
							<xsl:value-of select="PollingStation/PollingStationAddress" />
						</div>
						<p>
							<xsl:value-of select="VotingMethod" />
						</p>
					</div>
					<div class='left map-section'>
						<xsl:call-template name="colchester-map">
							<xsl:with-param name="address" select="PollingStation/PollingStationAddress"/>
						</xsl:call-template>
					</div>
				</div>
				<div class='clear'> </div>
			</xsl:with-param>
		</xsl:call-template>
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

	<xsl:template name="no-election-detail">
		<div class="no-election-details">
			You currently don't have an election number registered. 
		</div>	
	</xsl:template>

</xsl:stylesheet>
