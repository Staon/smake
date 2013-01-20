<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output
    method="html"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    indent="yes"
    encoding="utf-8"/>

  <xsl:template match="/">
    <html xmlns="http://www.w3.org/1999/xhtml">
      <head>
        <link href="report.css" type="text/css" rel="stylesheet"/>
        <title>Compilation report - <xsl:value-of select="smake_report/report/begin"/></title>
      </head>
      <body>
        <h2>Compilation report</h2>
        <p>
          <ul>
            <li>Start of compilation: <xsl:value-of select="smake_report/report/begin"/></li>
            <li>End of compilation: <xsl:value-of select="smake_report/report/end"/></li>
            <li>Time of compilation: <xsl:value-of select="smake_report/report/time"/></li>
          </ul>
        </p>
        <a name="brief_list"/>
        <h3>Brief list of errors</h3>
        <p><ul><xsl:apply-templates mode="brief"/></ul></p>
        <a name="full_list"/>
        <h3>Full list of errors</h3>
        <p><xsl:apply-templates mode="full"/></p>
      </body>
    </html>
  </xsl:template>
  
  <!-- brief list of errors -->
  <xsl:template match="error" mode="brief">
      <li>
        <a href="#error_{position()}">
          Error #<xsl:value-of select="position()"/>
        </a>: 
        <xsl:apply-templates mode="brief"/>
      </li>
  </xsl:template>

  <xsl:template match="warning" mode="brief">
      <li>
        <a href="#warning_{position()}">
          Warning #<xsl:value-of select="position()"/>
        </a>: 
        <xsl:apply-templates mode="brief"/>
      </li>
  </xsl:template>
  
  <xsl:template match="taskmsg" mode="brief">
      <li>
        <a href="#taskmsg_{position()}">
          Task message #<xsl:value-of select="position()"/>
        </a>: 
        <xsl:apply-templates mode="brief"/>
      </li>
  </xsl:template>
  
  <xsl:template match="project" mode="brief">
    <span class="prjname"><xsl:value-of select="."/></span>
  </xsl:template>
  
  <xsl:template match="path" mode="brief">
    <!-- <span class="prjpath"> (<xsl:value-of select="."/>)</span> -->
  </xsl:template>

  <xsl:template match="command" mode="brief"/>

  <xsl:template match="message" mode="brief">
    (<span class="brief_message"><xsl:value-of select="substring(string(.), 0, 100)"/>...</span>)
  </xsl:template>

  <xsl:template match="report" mode="brief"/>
  
  <!-- full list of errors -->
  <xsl:template match="error" mode="full">
    <div class="error">
      <a name="error_{position()}"/>
      <xsl:apply-templates mode="full"/>
    </div>
    <a class="backlink" href="#brief_list">Brief list</a>
  </xsl:template>

  <xsl:template match="warning" mode="full">
    <div class="warning">
      <a name="warning_{position()}"/>
      <xsl:apply-templates mode="full"/>
    </div>
    <a class="backlink" href="#brief_list">Brief list</a>
  </xsl:template>    

  <xsl:template match="taskmsg" mode="full">
    <div class="taskmsg">
      <a name="taskmsg_{position()}"/>
      <xsl:apply-templates mode="full"/>
    </div>
    <a class="backlink" href="#brief_list">Brief list</a>
  </xsl:template>    
    
  <xsl:template match="project" mode="full">
    <div class="title">Project: <span class="prjname"><xsl:value-of select="." /></span></div>
  </xsl:template>
  
  <xsl:template match="path" mode="full">
    <div class="title">Path: <span class="prjpath"><xsl:value-of select="."/></span></div>
  </xsl:template>
  
  <xsl:template match="command" mode="full">
    <div class="title">Command: <span class="command"><xsl:value-of select="."/></span></div>
  </xsl:template>

  <xsl:template match="message" mode="full">
    <div class="msgfield">
      <xsl:for-each select="line">
        <div class="msgline"><xsl:value-of select="."/></div>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="report" mode="full"/>
</xsl:stylesheet>
