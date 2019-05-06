# markentries
markup DITA maps and bookmaps for glossary entries

# Using markentries

## Usage
```
markentries [-s|-m|-f] <Excel file> <ditmap>
```
### Summary
markentries allows you to use an Excel spreadsheet to maintain glossary entries, then use that spreadsheet to mark the first instance of the terms in each topic listed in the DITA map or bookmap.

<hr>
*Note:* 

Associated project here: 
- [excel2glossary](https://github.com/wbrisett/excel2glossary) 

This script creates glossary entries out of the Excel Spreadsheet for you.
<hr>

Terms found in the DITA topics use keydefs and are mapped to the actual word minus any invalid XML characters and white space. For example:
```
<abbreviated-form keyref="advancedperipheralbus" />
```
Keys are mapped to the topics using the ***glossaryentries.ditamap***. 

### Options
    -f, --first.    markup only first occurrence of word in a topic.
    -m, --mulitple  markup multiple occurrences of words in a topic.
    -s, --single    markup only a single occurrence of word in map or bookmap.

*If no option us set, first occurrence in each topic is used.* 

## Excel Format
The first row is considered the header row and will never be processed. The spreadsheet structure looks like this:

<table>
<tr>
	<th>Term</th>
	<th>Definition</th>
	<th>Acronym</th>
</tr>
<tr>
	<td>actual term</td>
	<td>actual definition</td>
	<td>actual acryonym</td>
</tr>
</table>

The third column, the acronym, is optional. If used, the glossary for that term will use the expanded form for the DITA glossary. There is no requirement for an acronym, and you can have a mix of terms with and without acronyms. 

An Excel template is included in the build.

### Sample

<table>
<tr>
	<th>Term</th>
	<th>Definition</th>
	<th>Acronym</th>
</tr>
<tr>
	<td>AXI Coherency Extensions</td>
	<td>The AXI Coherency Extensions (ACE) provide additional channels and signaling to an AXI interface to support system level cache coherency.</td>
	<td>ACE</td>
</tr>
<tr>
<td>ACE protocol</td>
<td>The AXI Coherency Extensions protocol, that adds signals to an AMBA AXI4 interface, to support managing the coherency of a distributed memory system.</td>
<td></td>
</table>

## Requirements

* Ruby 2.x
* Ruby gems: 
  * Nokogiri
  * creek
* Excel spreadsheet with terms, definitions, and optional acronyms.


### Getting started with Ruby

If you haven't ever used ruby, you may need to install it. 

- [ruby language](https://www.ruby-lang.org/en/downloads/)

There are versions for linux, Mac OS X, and Windows.
Ruby gems are libraries used to perform certain things. I used two for this project; creek is used to read the Excel data, nokogiri is the XML library used to read and write XML data. 

After Ruby is installed, you need to install the libraries. This is done by running: 
```
bundler install
```
This will look at your Ruby gems and install any needed gems for this script. 
