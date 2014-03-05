<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
	<xsl:param name="return_path" />
	<xsl:param name="username" />
	<xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
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
			</content>
		</response>
	</xsl:template>


	<xsl:template match="XpressElections">
			<div class='left'><span><b>Electoral number: </b> </span><span><xsl:value-of select="ElectoralNumber" /></span></div>
			<div class='clear'> </div>
	</xsl:template>

	<xsl:template match="Election">
		<div>
			<b><xsl:value-of select="ElectionTitle" /></b>
		</div>
	</xsl:template>


		<xsl:template name="no-election-detail">
			<div class="no-account">
			<div class="no-election-details">
				You currently don't have an election number registered. 
			</div>	
		</div>
		</xsl:template>

</xsl:stylesheet>
