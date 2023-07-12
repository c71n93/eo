<?xml version="1.0" encoding="UTF-8"?>
<!--
The MIT License (MIT)

Copyright (c) 2016-2023 Objectionary.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:eo="https://www.eolang.org" xmlns:g="http://www.w3.org/2001/03/XPath/grammar" id="to-ebnf" version="2.0">
  <xsl:output method="text" encoding="UTF-8"/>
  <xsl:function name="eo:escape" as="xs:string">
    <xsl:param name="s" as="xs:string"/>
    <xsl:variable name="r0" select="$s"/>
    <xsl:variable name="r1" select="replace($r0, '\\', '\\textbackslash{}')"/>
    <xsl:variable name="r2" select="replace($r1, '\{', '\\char`\\{')"/>
    <xsl:variable name="r3" select="replace($r2, '\}', '\\char`\\}')"/>
    <xsl:variable name="r4" select="replace($r3, '&amp;', '\\&amp;')"/>
    <xsl:variable name="r5" select="replace($r4, ' ', '\\textvisiblespace{}')"/>
    <xsl:variable name="r6" select="replace($r5, '\^', '\\^{}')"/>
    <xsl:variable name="r7" select="replace($r6, '\$', '\\textdollar')"/>
    <xsl:variable name="r8" select="replace($r7, '#', '\\#')"/>
    <xsl:variable name="r9" select="replace($r8, '_', '\\_')"/>
    <xsl:variable name="r10" select="replace($r9, '&quot;', '\\lq\\lq')"/>
    <xsl:value-of select="$r10"/>
  </xsl:function>
  <xsl:function name="eo:term" as="xs:string">
    <xsl:param name="t" as="xs:string"/>
    <xsl:variable name="r">
      <xsl:choose>
        <xsl:when test="$t = 'eol'">
          <xsl:text>'EOL'</xsl:text>
        </xsl:when>
        <xsl:when test="$t = 'eop'">
          <xsl:text>'EOP'</xsl:text>
        </xsl:when>
        <xsl:when test="$t = 'tab'">
          <xsl:text>'TAB'</xsl:text>
        </xsl:when>
        <xsl:when test="$t = 'untab'">
          <xsl:text>'UNTAB'</xsl:text>
        </xsl:when>
        <xsl:when test="$t = 'eof'">
          <xsl:text>'EOF'</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>&lt;</xsl:text>
          <xsl:value-of select="$t"/>
          <xsl:text>&gt;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:value-of select="$r"/>
  </xsl:function>
  <xsl:template match="g:grammar">
    <xsl:element name="ebnf">
      <xsl:text>% Use native-enbf LaTeX package to render this</xsl:text>
      <xsl:text>
</xsl:text>
      <xsl:apply-templates select="g:production[@name!='eof' and @name!='eol' and @name!='eop']"/>
    </xsl:element>
  </xsl:template>
  <xsl:template match="g:production">
    <xsl:value-of select="eo:term(eo:escape(@name))"/>
    <xsl:text> := </xsl:text>
    <xsl:apply-templates select="g:*"/>
    <xsl:text> \\
</xsl:text>
  </xsl:template>
  <xsl:template match="g:optional">
    <xsl:text> [ </xsl:text>
    <xsl:apply-templates select="g:*"/>
    <xsl:text> ] </xsl:text>
  </xsl:template>
  <xsl:template match="g:zeroOrMore">
    <xsl:text> { </xsl:text>
    <xsl:apply-templates select="g:*"/>
    <xsl:text> } </xsl:text>
  </xsl:template>
  <xsl:template match="g:oneOrMore">
    <xsl:if test="count(g:*) &gt; 1">
      <xsl:text> ( </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="g:*"/>
    <xsl:if test="count(g:*) &gt; 1">
      <xsl:text> ) </xsl:text>
    </xsl:if>
    <xsl:text> { </xsl:text>
    <xsl:apply-templates select="g:*"/>
    <xsl:text> } </xsl:text>
  </xsl:template>
  <xsl:template match="g:sequence">
    <xsl:if test="count(g:*) &gt; 1">
      <xsl:text> ( </xsl:text>
    </xsl:if>
    <xsl:apply-templates select="g:*"/>
    <xsl:if test="count(g:*) &gt; 1">
      <xsl:text> ) </xsl:text>
    </xsl:if>
  </xsl:template>
  <xsl:template match="g:choice">
    <xsl:variable name="txt">
      <xsl:for-each select="g:*">
        <xsl:if test="position() &gt; 1">
          <xsl:text> | </xsl:text>
        </xsl:if>
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="ancestor::g:production[count(child::*) = 1]">
        <xsl:value-of select="$txt"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> ( </xsl:text>
        <xsl:value-of select="$txt"/>
        <xsl:text> ) </xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="g:string">
    <xsl:text> "</xsl:text>
    <xsl:value-of select="eo:escape(text())"/>
    <xsl:text>" </xsl:text>
  </xsl:template>
  <xsl:template match="g:complement">
    <xsl:apply-templates select="g:*"/>
  </xsl:template>
  <xsl:template match="g:charClass">
    <xsl:text> /[</xsl:text>
    <xsl:if test="ancestor::g:complement">
      <xsl:text>\^{}</xsl:text>
    </xsl:if>
    <xsl:apply-templates select="g:*"/>
    <xsl:text>]/ </xsl:text>
  </xsl:template>
  <xsl:template match="g:charRange">
    <xsl:value-of select="@minChar"/>
    <xsl:text>-</xsl:text>
    <xsl:value-of select="@maxChar"/>
  </xsl:template>
  <xsl:template match="g:charCode">
    <xsl:variable name="txt">
      <xsl:text>\textbackslash{}</xsl:text>
      <xsl:choose>
        <xsl:when test="@value = '9'">
          <xsl:text>t</xsl:text>
        </xsl:when>
        <xsl:when test="upper-case(@value) = 'A'">
          <xsl:text>n</xsl:text>
        </xsl:when>
        <xsl:when test="upper-case(@value) = 'D'">
          <xsl:text>r</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>x</xsl:text>
          <xsl:value-of select="upper-case(@value)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="ancestor::g:charClass">
        <xsl:value-of select="$txt"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>"</xsl:text>
        <xsl:value-of select="$txt"/>
        <xsl:text>"</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="g:char">
    <xsl:value-of select="eo:escape(text())"/>
  </xsl:template>
  <xsl:template match="g:ref">
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="matches(@name, '^[A-Z].*')">
        <xsl:text>'</xsl:text>
        <xsl:value-of select="eo:escape(@name)"/>
        <xsl:text>'</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="eo:term(eo:escape(@name))"/>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
  </xsl:template>
</xsl:stylesheet>
