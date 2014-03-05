<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:php="http://php.net/xsl" xmlns:fn="http://www.w3.org/2005/xpath-functions" version="1.0">
  <xsl:param name="return_path" />
  <xsl:include href="sites/all/modules/custom/achieveservice/achieveservice_ws/stylesheets/lib/common.xsl" />
  <xsl:variable name="description">Benefits</xsl:variable>
  <xsl:variable name="correspondence_history_path">firmstep/selfservice/accounts/benefitscorrespondence/</xsl:variable>
  
  <xsl:template match="/">
    <response>
      <title><h1 id="my-tasks-header">Benefits</h1></title>
      <content>
        <xsl:choose>
	        <xsl:when test="count(feed/ServicesResponseEnvelope/claims/claim/reference) = 0">
		        You currently don't have any benefits registered.
	        </xsl:when>
	        <xsl:otherwise>
            <xsl:apply-templates select="feed/ServicesResponseEnvelope/claims" />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:call-template name="links" />
      </content>
    </response>
  </xsl:template>
  
  <!-- Related links -->
  <xsl:template name="links" >
    <div class="global-links">
      <xsl:for-each select="/feed/ServicesResponseEnvelope/claims[1]/links">
        <!-- Output non-internal form links -->
        <xsl:for-each select="link[(not(@rel) or @rel!='internal') and @type='form']">
          <xsl:apply-templates select="." />
        </xsl:for-each>
      </xsl:for-each>
    </div>
    <div class='clear'></div>
  </xsl:template>
  
  <xsl:template match="link[@type='form']">
    <a>
      <xsl:attribute name="href">
        <xsl:value-of select="php:function('base_path')" />
        <xsl:value-of select="'default.aspx/'"/>
        <xsl:value-of select="@href" />
        <xsl:value-of select="'&amp;FinishURL=/../'"/>
        <xsl:value-of select="$return_path" />
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:value-of select="@title" />
      </xsl:attribute>
      <xsl:value-of select="@title" />
    </a>
  </xsl:template>
  
  <!-- Main -->
  <xsl:template match="claims">
    <xsl:call-template name="expandable">
      <xsl:with-param name="expanded" select="count(ancestor::ServicesResponseEnvelope/claims) = 1"/>
      <xsl:with-param name="title">
        <xsl:value-of select="concat('Reference: ', claim/reference)"/>
      </xsl:with-param>
      <xsl:with-param name="body">
        <xsl:apply-templates select="claim" />
	      <div class="clear"></div>
	      <div class="column1">
          <xsl:for-each select="correspondence">
            <xsl:call-template name="correspondence-summary">
              <xsl:with-param name="index" select="1"/>
            </xsl:call-template>
          </xsl:for-each>
<!--
            <div class="correspondence">
              <xsl:apply-templates select="correspondence" />
            </div>
-->
	      </div>
	      <div class="column2">
            <div class="overpayments">
              <xsl:apply-templates select="invoices" />
            </div>
	      </div>
        <div class='clear'></div>
	    </xsl:with-param>
	  </xsl:call-template>
  </xsl:template>

  <xsl:template match="claim">
    <div class="claim">
      <span class="claimant resident"><xsl:value-of select="claimantName" /></span>
      <div class="claim-details">
        <div class="claim-reference">
          <span class="label">Reference: </span>
          <xsl:value-of select="reference" />
        </div>      
        <div class="claim-reference">
          <span class="label">Type: </span>
          <xsl:value-of select="type" />
        </div>      
         <div class="claim-reference">
          <span class="label">Status: </span>
          <xsl:value-of select="status" />
        </div>
      </div>
    </div>
    <div class="clear"></div>
    <div class="column1">
      <xsl:if test="benefits[node()]">
        <div class="benefits">
          <xsl:apply-templates select="benefits/benefit" />
        </div>
      </xsl:if>
      <xsl:if test="calcInfo[node()]">
        <div class="calculations" id="benefits-calculations">
          <xsl:apply-templates select="calcInfo" />
        </div>
      </xsl:if>
    </div>
    <div class="column2">
      <xsl:if test="household[node()]">
        <div class="residents">
          <xsl:apply-templates select="household" />
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- Benefits -->
  <xsl:template match="benefit">
    <div class="benefit">
	    <h3><xsl:value-of select="type" /> Benefit</h3>
      <table class="horizontal">
        <tbody>
          <tr>
            <th>Weekly amount</th>
            <td><xsl:call-template name="money"><xsl:with-param name="amount" select="currWeeklyAmount"/></xsl:call-template></td>
          </tr>
          <tr>
            <th>Until</th>
            <td><xsl:call-template name="date"><xsl:with-param name="date" select="dateTo" /></xsl:call-template></td>
          </tr>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <!-- Calculations -->
  <xsl:template match="calcInfo">
    <xsl:call-template name="expandable">
	    <xsl:with-param name="title">How this was calculated</xsl:with-param>
	    <xsl:with-param name="body">
		    <xsl:if test="incomeCalc[node()]">
			    <xsl:apply-templates select="incomeCalc" />
		    </xsl:if>
		    <xsl:if test="housingBenefitCalc[node()]">
			    <xsl:apply-templates select="housingBenefitCalc" />
		    </xsl:if>
		    <xsl:if test="councilTaxBenefitCalc[node()]">
			    <xsl:apply-templates select="councilTaxBenefitCalc" />
		    </xsl:if>
	    </xsl:with-param>
	  </xsl:call-template>
  </xsl:template>
  
  <!-- Income Calculations -->
  <xsl:template match="incomeCalc">
    <div class="income-calc">
      <h3>Income Calculation</h3>
      <table class="horizontal">
        <tr>
          <th>Gross Income</th>
          <td><xsl:call-template name="money"><xsl:with-param name="amount" select="grossWeeklyAmt" /></xsl:call-template></td>
        </tr>
        <tr>
          <th>Disregards</th>
          <td><xsl:call-template name="money"><xsl:with-param name="amount" select="weeklyDisregard" /></xsl:call-template></td>
        </tr>
        <tr>
          <th>Net Income</th>
          <td><xsl:call-template name="money"><xsl:with-param name="amount" select="netWeeklyAmt" /></xsl:call-template></td>
        </tr>
		
		<tr>
		  <th>Applicable Amount</th>
		  <td><xsl:call-template name="money"><xsl:with-param name="amount" select="totalApplicableAmt" /></xsl:call-template></td>
		</tr>
		
		<tr>
		  <th>Excess Income (if positive)</th>
		  <td><xsl:call-template name="money"><xsl:with-param name="amount" select="excessIncome" /></xsl:call-template></td>
		</tr>
      </table>
    </div>
  </xsl:template>

  <!-- Housing Benefit Calculations -->
  <xsl:template match="housingBenefitCalc">
    <div class="housing-benefit-calc">
      <h3>Housing Benefit Calculation</h3>
      <table class="horizontal">
        <tr>
          <th>Weekly Eligible Amount</th>
          <td><xsl:call-template name="money"><xsl:with-param name="amount" select="weeklyEligRent" /></xsl:call-template></td>
        </tr>
		<tr>
		  <th>Less Non-Dependants</th>
		  <td><xsl:call-template name="money"><xsl:with-param name="amount" select="weeklyNonDepDeductHB" /></xsl:call-template></td>
		</tr>
		<tr>
		  <th>Less Two Strikes Sanction</th>
		  <td><!-- cannot find this in data --></td>
		</tr>
		
		<tr>
		  <th>Max Housing Benefit</th>
		  <td><xsl:call-template name="money"><xsl:with-param name="amount" select="maxHousingBenefit" /></xsl:call-template></td>
		</tr>
		<tr>
		  <th>Less 65.00% of Excess Income</th>
		  <td><xsl:call-template name="money"><xsl:with-param name="amount" select="excessIncome65Per" /></xsl:call-template></td>
		</tr>
		<tr>
		  <th>Weekly Housing Benefit</th>
		  <td><xsl:call-template name="money"><xsl:with-param name="amount" select="weeklyHousingBenefit" /></xsl:call-template></td>
		</tr>
		
	  </table>
    </div>
  </xsl:template>
  
  <!-- Council Tax Benefit Calculations -->
  <xsl:template match="councilTaxBenefitCalc">
	<xsl:variable name="use_alternative" select="(weeklyCouncilTaxBenefitAlt != '') and ((weeklyCouncilTaxBenefitMain = '') or (weeklyCouncilTaxBenefitAlt > weeklyCouncilTaxBenefitMain))" />
	<div class='clear'></div>
    <div class="council-tax-benefit-calc">
      <h3>Council Tax Benefit Calculation</h3>
	  <table class="horizontal">
	  
		<xsl:choose>
		  <xsl:when test="$use_alternative">
	        <tr>
		      <th>Weekly Council Tax</th>
		      <td><xsl:call-template name="money"><xsl:with-param name="amount" select="weeklyEligCouncilTaxAlt" /></xsl:call-template></td>
		    </tr>
		  </xsl:when>
		  <xsl:otherwise>
	        <tr>
		      <th>Weekly Council Tax</th>
		      <td><xsl:call-template name="money"><xsl:with-param name="amount" select="weeklyEligCouncilTaxMain" /></xsl:call-template></td>
		    </tr>
		  </xsl:otherwise>
		</xsl:choose>
		
	    <tr>
		  <th>Less Non-Dependants</th>
		  <td><xsl:call-template name="money"><xsl:with-param name="amount" select="weeklyNonDepDeductCTax" /></xsl:call-template></td>
		</tr>
	    <tr>
		  <th>Less Two Strikes Sanction</th>
		  <td><!-- cannot find this in the data --></td>
		</tr>
		
		<xsl:choose>
		  <xsl:when test="$use_alternative">
		    <tr>
		      <th>Max CTax Rebateable</th>
		      <td><xsl:call-template name="money"><xsl:with-param name="amount" select="maxCouncilTaxBenefitAlt" /></xsl:call-template></td>
		    </tr>
		  </xsl:when>
		  <xsl:otherwise>
		    <tr>
		      <th>Max CTax Rebateable</th>
		      <td><xsl:call-template name="money"><xsl:with-param name="amount" select="maxCouncilTaxBenefitMain" /></xsl:call-template></td>
		    </tr>
		  </xsl:otherwise>
		</xsl:choose>
		
		<tr>
		  <th>Less 20.00% of Excess Income</th>
		  <td><xsl:call-template name="money"><xsl:with-param name="amount" select="excessIncome20Per" /></xsl:call-template></td>
		</tr>
		
		<xsl:choose>
		  <xsl:when test="$use_alternative">
		    <tr>
		      <th>Weekly CTax Benefit</th>
		      <td>
				<span title='Alt; Main: {weeklyCouncilTaxBenefitMain}'>
				  <xsl:call-template name="money"><xsl:with-param name="amount" select="weeklyCouncilTaxBenefitAlt" /></xsl:call-template>
				</span>
			  </td>
		    </tr>
		  </xsl:when>
		  <xsl:otherwise>
		    <tr>
		      <th>Weekly CTax Benefit</th>
		      <td>
				<span title='Main; Alt: {weeklyCouncilTaxBenefitAlt}'>
			      <xsl:call-template name="money"><xsl:with-param name="amount" select="weeklyCouncilTaxBenefitMain" /></xsl:call-template>
				</span>
			  </td>
		    </tr>
		  </xsl:otherwise>
		</xsl:choose>
		
		<!--
		<tr>
		  <th>Alternative Income</th>
		  <td><xsl:call-template name="money"><xsl:with-param name="amount" select="CTaxAltInc"/></xsl:call-template></td>
		</tr>
		-->
		
	  </table>
	</div>
  </xsl:template>

  <!-- Resident -->
  <xsl:template match="household">
    <div class="residents">
      <h3>Household</h3>
      <table>
        <thead>
          <tr>
            <th>Name</th>
            <th>Date of Birth</th>
            <th>Status</th>
            <th>More information</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="residents/resident">
            <tr>
              <xsl:attribute name="class">
                <xsl:if test="position() mod 2">odd</xsl:if>
              </xsl:attribute>
              <td><xsl:value-of select="name" /></td>
              <td><xsl:call-template name="date"><xsl:with-param name="date" select="dob" /></xsl:call-template></td>
              <td><xsl:value-of select="status" /></td>
              <td>
                <xsl:if test="working = 'Y'">Working</xsl:if>
                <xsl:if test="student = 'Y'">Student</xsl:if>
                <xsl:if test="carer = 'Y'">Carer</xsl:if>
                <xsl:if test="disabilityStatus != ''">Disability: <xsl:value-of select="disabilityStatus" /></xsl:if>
                <xsl:if test="inHospital = 'Y'">In Hospital</xsl:if>
                <xsl:if test="inResidentialAccom = 'Y'">In Residential Accommodation</xsl:if>
                <xsl:if test="meals = 'Y'">Meals: <xsl:value-of select="mealsType" /></xsl:if>
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>

  <!-- Overpayments -->
  <xsl:template match="invoices">
    <div class="overpayments">
      <h3>Overpayments</h3>
      <xsl:if test="count(invoice) = 0">
	    (No overpayments.)
	  </xsl:if>
      <xsl:apply-templates select="invoice" />
    </div>
  </xsl:template>

  <!-- Individual invoice -->
  <xsl:template match="invoice">
    <div class="invoice">
      <h4>
        <xsl:text>Invoice </xsl:text>
        <xsl:value-of select="invoiceNumber" />
      </h4>
      <div class="invoice-due">
        <span class="label">Due date: </span>
        <xsl:call-template name="date"><xsl:with-param name="date" select="dueDate" /></xsl:call-template>
      </div>
      <div class="original-balance">
        <span class="label">Original balance: </span>
        <xsl:call-template name="money"><xsl:with-param name="amount" select="balanceOrig"/></xsl:call-template>
      </div>
      <div class="outstanding-balance">
        <span class="label">Outstanding: </span>
        <xsl:call-template name="money"><xsl:with-param name="amount" select="balanceOutstanding"/></xsl:call-template>
      </div>
      <div class="payee">
        <span class="label">Payee: </span>
        <xsl:value-of select="payeeName" />
      </div>
      <table>
        <thead>
          <tr>
            <th>Date</th>
            <th>Amount</th>
            <th>Description</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="lineitem">
            <tr>
              <xsl:attribute name="class">
                <xsl:if test="position() mod 2">odd</xsl:if>
              </xsl:attribute>
              <td><xsl:call-template name="date"><xsl:with-param name="date" select="transactionDate" /></xsl:call-template></td>
              <td><xsl:call-template name="money"><xsl:with-param name="amount" select="amount"/></xsl:call-template></td>
              <td><xsl:value-of select="description" /></td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
  </xsl:template>
</xsl:stylesheet>
