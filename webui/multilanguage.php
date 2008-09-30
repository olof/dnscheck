<?php
	
	$translationIndex = array(
		"Home",
		"FAQ",
		"A service from .SE",
		"Test your DNS-server and find errors",
		"Enter your domain name in the field below to test the DNS-servers that are used.",
		"Test now",
		"Basic results",
		"Advanced results",
		"Test history",
		"Error loading history",
		"No test history found",
		"Page",
		".SE (The Internet Infrastructure Foundation)",
		"Domain doesn't exist",
		"The domain you entered doesn't seem to be registered",
		"Loading",
		"Waiting for the test results to be loaded",
		"All tests are ok",
		"Warnings found in test",
		"Errors found in test",
		"About DNSCheck",
		"DNSCheck info",
		"About DNS",
		"DNS info",
		"DNSCheck FAQ",
		"DNSCheck FAQ contents",
		"Explanation",
		"Test was ok",
		"Test contains warnings",
		"Test contains errors",
		"Test was not performed"
	);
	
	$translationMap = array(
		"en" => array(
			"Home",
			"FAQ",
			"A service from .SE",
			"Test your DNS-server and find errors",
			"Enter your domain name in the field below to test the DNS-servers that are used. Example: iis.se",
			"Test now",
			"Basic results",
			"Advanced results",
			"Test history",
			"Error loading history",
			"No test history found",
			"Page",
			".SE (The Internet Infrastructure Foundation)",
			"Domain doesn't exist",
			"The domain you provided doesn't seem to be delegated or was entered incorrectly. You need to enter only the domain name, like &quot;iis.se&quot;, not the name of a subdomain, like &quot;dev.iis.se&quot; or a webserver like &quot;www.iis.se&quot;.",
			"Loading",
			"Waiting for the test results to be loaded",
			"All tests are ok",
			"Warnings found in test",
			"Errors found in test",
			"About DNSCheck",
			"<img src='_img/img_trafficlight.png' alt='Trafficlight' class='right' /><p>DNSCheck is a program that was designed to help people check, measure and hopefully also understand the workings of the Domain Name System, DNS. When a domain (aka zone) is submitted to DNSCheck it will investigate the domain's general health by traversing the DNS from root (.) to the TLD (Top Level Domain, like .SE) to eventually the nameserver(s) that holds the information about the specified domain (like iis.se). Some other sanity checks, for example measuring host connectivity, validity of IP-addresses and control of DNSSEC signatures will also be performed.</p>",
			"About the domain name system, DNS",
			"<p>The domain name system (DNS in short) is what could be called the &#8220;phone book&#8221; of the Internet. It keeps track of the mapping of, for example, a human-readable website name (like www.iis.se) to the slightly more arcane form of an IP-address that the computer needs to initiate communication (in this case 212.247.7.229). </p><p>Besides browsing the Internet with your web browser using website names instead of IP-addresses the DNS also makes sure your emails find their way. In short, a stable DNS is vital for most companies to maintain a working and efficient operation.</p>",
			"DNSCheck FAQ",
			'<h5 id="findex">Index</h5> 
			<ol>

				<li><a href="#f1">What is DNSCheck?</a></li>
				<li><a href="#f2">What is DNS?</a></li>
				<li><a href="#f3">What about www.dnscheck.se?</a></li>
				<li><a href="#f4">Why a new DNSCheck?</a></li>
				<li><a href="#f5">How does DNSCheck work?</a></li>
				<li><a href="#f6">How can DNSCheck help me?</a></li>
				<li><a href="#f7">DNSCheck goes &quot;Error&quot;/&quot;Warning&quot; on my domain, what does it mean?</a></li>
				<li><a href="#f8">How can DNSCheck judge what is right and wrong?</a></li>
				<li><a href="#f9">Does DNSCheck handle IPv6?</a></li>
				<li><a href="#f10">Does DNSCheck handle DNSSEC?</a></li>
				<li><a href="#f11">What makes DNSCheck differ from other zone controlling software?</a></li>
				<li><a href="#f12">Will DNSCheck work for my non-.se-domain?</a></li>
				<li><a href="#f13">DNSCheck and privacy</a></li>
				<li><a href="#f14">How come I can&rsquo;t test my domain?</a></li>
				<li><a href="#f15">What kind of queries does DNSCheck generate?</a></li>

			</ol>
			<div class="divider"></div>

			<h5 id="f1">What is DNSCheck?</h5>

			<p>DNSCheck is a program that was designed to help people check, measure and hopefully also understand the workings of the Domain Name System, DNS. When a domain (aka zone) is submitted to DNSCheck it will investigate the domain&rsquo;s general health by traversing the DNS from root (.) to the TLD (Top Level Domain, like .SE) to eventually the nameserver(s) that holds the information about the specified domain (like iis.se). Some other sanity checks, for example measuring host connectivity, validity of IP-addresses and control of DNSSEC signatures will also be performed. </p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f2">What is DNS?</h5>

			<p>The domain name system (DNS in short) is what could be called the &ldquo;phone book&rdquo; of the Internet. It keeps track of the mapping of, for example, a human-readable website name (like www.iis.se) to the slightly more arcane form of an IP-address that the computer needs to initiate communication (in this case 212.247.7.229). <br />
	        Besides browsing the Internet with your web browser using website names instead of IP-addresses the DNS also makes sure your emails find their way to the right recipient. In short, a stable DNS is vital for most companies to maintain a working and efficient operation.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f3">What about www.dnscheck.se?</h5>

			<p>The webpage <a href="http://www.dnscheck.se">www.dnscheck.se</a> points to an earlier version of DNSCheck that .SE developed with the help of Patrik F&auml;ltsr&ouml;m of Frobbit AB. The new version of DNSCheck resides in <a href="http://dnscheck.iis.se">dnscheck.iis.se</a> and was developed by Jakob Schlyter of Kirei AB.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f4">Why a new DNSCheck?</h5>

			<p>.SE wanted a better control of the code and also the ability to reuse parts of the DNSCheck code in other projects. Thus we came to the conclusion that it was a better idea to start from scratch and build a modular codebase that we could also add new features to, like for example ipv6- and dnssec-controls.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f5">How does DNSCheck work?</h5>

			<p>If you want the technical information about how DNSCheck operates you are advised to check the wiki/trac connected to the DNSCheck open source project. This is the URL: <a href="http://opensource.iis.se/trac/dnscheck/wiki/Architecture">http://opensource.iis.se/trac/dnscheck/wiki/Architecture</a> . If you want a less technical answer you should check the first FAQ-question: &ldquo;What is DNSCheck&rdquo;.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f6">How can DNSCheck help me?</h5>

			<p>The current version of DNSCheck was made for technicians or at least people who are interested to learn more about how the DNS operates. If you merely want to show whoever is in charge of your domain (the tech-c or technical staff at your name server provider) that there in fact is a problem with your domain you can use the link that appears on the bottom of the page after each test. So if you have run a test and want to show someone the result of that specific test you can just copy the link at the bottom of the page that displays your test results. The link below, for example, points at a previous test on "iis.se":</p> <p> <a href="http://dnscheck.iis.se/?time=1220357126&id=66&view=basic">http://dnscheck.iis.se/?time=1220357126&id=66&view=basic </p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f7">DNSCheck goes &quot;Error&quot;/&quot;Warning&quot; on my domain, what does it mean?</h5>

			<p>Of course, this depends on what kind of test failed for your zone. In most cases you can press the actual error/warning-message and in so doing get more detailed information about what kind of problem that was found.</p>
			<p>As an example if we test the domain "iis.se" and recieve an error titled &ldquo;<strong>Name server ns.nic.se (212.247.7.228) does not answer queries over UDP</strong>&rdquo;. What does this mean? After we click this message more detailed information become visible. More specific this: &ldquo;<strong>The name server failed to answer queries sent over UDP. This is probably due to the name server not correctly set up or due to misconfigured filtering in a firewall.</strong>&rdquo;. Luckily this was just an example, that error basically means the name server is down so it&rsquo;s not the most harmless error around. </p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f8">How can DNSCheck judge what is right and wrong?</h5>

			<p>There is no  final judgement of the health of a domain that can be bestowed by anyone. This  is very important. .SE and the people behind DNSCheck do not claim that  DNSCheck is correct in every aspect. Sometimes opinions differ, especially  between countries, but sometimes also locally. We have had the luck to have the  help of an extremely competent DNS-group here in Sweden. Hopefully their opinions in  combination with ours have made a good compromise between what is an actual  potentially dangerous error and what could be merely seen as a notice or  warning.</p>
			<p>But as with  all things as evolving as DNS the situation is most likely changing, what is a  notice today could be an error tomorrow. If you really think we&rsquo;ve made a  mistake in our judgement please don&rsquo;t hesitate to drop us an email at <a href="mailto:dnscheck@iis.se">dnscheck@iis.se</a> with a link to your test and an explanation why you think it shows something that you consider incorrect. ( If you don&rsquo;t know how to find the link to your test, check the "How can DNSCheck help me"-part of this FAQ ).</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f9">Does DNSCheck handle IPv6?</h5>

			<p>Yes, it  does. However, since .SE currently doesn&rsquo;t have IPv6-connectivity these tests  cannot be performed. As soon as IPv6-connectivity is established we will test  IPv6 in the same way we test IPv4.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f10">Does DNSCheck handle DNSSEC?</h5>

			<p>Yes, if  DNSSEC is available on a domain that is sent to DNSCheck it will be checked  automatically.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f11">What makes DNSCheck differ from other zone controlling software?</h5>

			<p>First of  all this DNSCheck saves all history from earlier tests, which means you can go  back to a test you did a week ago and compare it to the test you ran a moment  ago.<br />
			<br />
			DNSCheck also controls that the name servers a zone has used previously no longer  contains information about the zone you&rsquo;re testing (this only applies to  .SE-domains that have been redelegated after February 2007). </p>
			<p>DNSCheck  will also try and explain the error/warning to you in a good way, although these  messages can be difficult to understand for a non-technician. The next version  of DNSCheck, that will be launched later this year, will be more compliant to  non-technician users.</p>
			<p>DNSCheck  will continuously scan the .SE-zone and report its health into the database.</p>
			<p>There&rsquo;s an  &ldquo;advanced&rdquo; tab for technicians who might want to use DNSCheck without the &ldquo;basic&rdquo; view.</p>
			<p>Lastly, this  open source version of DNSCheck was built using modular code which, basically,  means you can use parts of it in your systems, if you&rsquo;d want to. It&rsquo;s quite  rare that you&rsquo;d want a complete program just to check for example redelegations.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f12">Will DNSCheck work for my non-.se-domain?</h5>

			<p>Yes. All  the checks that occur for .SE-domains will be used on your zone as well.  However, the periodic sweep of the database (automatic checks basically) only  happens on .SE-domains, other than that it&rsquo;s identical.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f13">DNSCheck and privacy</h5>

                        <p>Since DNSCheck is open to everyone it is possible for anyone to check your domain and also see history from previous tests, however there is no way to tell who has run a specific test since nothing is logged except the time of the test.    </p>
                        <p><a href="#findex">Back to the top </a></p>

			<h5 id="f14">How come I can&rsquo;t test my domain?</h5>
                        
                        <p>If we skip the situation where the domain doesn&rsquo;t exist, as in you input a non-existing domain to DNSCheck, there are 2 other possibilites:  <br />
                        <br />

			1. To protect the engine from multiple identical inputs, that is the same IP checking the same zone several times, there is a delay of 5 minutes between identical subsequent tests. Which practically means that you can only test the same domain once every 5 minutes, if you try and test it again within 5 minutes the last results will be displayed instead.</p>
			
			 <p>2. Because DNSCheck was made to check domains (like iis.se) and not hostnames in a domain (like www.iis.se) the DNSCheck webpage will do a pre-control of your domain before it sends it on to the engine for testing. This shouldn&rsquo;t effect the great majority of domains out there but it CAN do so, because if the webpage decides a domain doesn&rsquo;t exist the check wont run. Sofar the only time we&rsquo;ve seen this is when a domains&rsquo; nameservers all lie within the domain that&rsquo;s being tested and these are very broken. We need to fix this, and please do report if you cannot check your domain so that we can see if anything else is wrong. This control will be improved, that&rsquo;s a promise.</p>

                        <p><a href="#findex">Back to the top </a></p>
			
			<h5 id="f15">What kind of queries does DNSCheck generate?</h5>

			<p>This  question is very hard to answer since DNSCheck will generate different queries  depending on how your name servers answer. The easiest way to get a full view  of what queries and results are generated is to run the &ldquo;dnscheck&rdquo; CLI command  and add the flag &ldquo;--raw&rdquo;. This will result in quite thorough information on  what is happening. However the output from this CLI-tool is quite heavily  technical so unless you&rsquo;re into bits and bytes you might want to skip this  step. :)</p>
			<p><a href="#findex">Back to the top </a></p>',
			"Explanation",
			"Test was ok",
			"Test contains warnings",
			"Test contains errors",
			"Test was not performed"
		),
		"se" => array(
			"Hem",
			"Vanliga fr&aring;gor",
			"En tj&auml;nst fr&aring;n .SE",
			"Testa din DNS-server och uppt&auml;ck fel",
			"Ange ditt dom&auml;nnamn nedan f&ouml;r att testa dess DNS-servrar.",
			"Testa nu",
			"F&ouml;renklat resultat",
			"Avancerat resultat",
			"Tidigare test",
			"Historiken kunde ej laddas",
			"Ingen historik finns",
			"Sida",
			".SE (Stiftelsen f&ouml;r Internetinfrastruktur)",
			"Dom&auml;nen finns inte",
			"Dom&auml;nen du angav verkar inte vara registrerad",
			"Laddar",
			"V&auml;ntar p&aring; testresultat",
			"Alla test &auml;r ok",
			"Testet inneh&ouml;ll varningar",
			"Testet inneh&ouml;ll fel",
			"Om DNSCheck",
			"<img src='_img/img_trafficlight.png' alt='Trafficlight' class='right' /><p>DNSCheck &auml;r ett program designat f&ouml;r att hj&auml;lpa m&auml;nniskor  att kontrollera, m&auml;ta och f&ouml;rhoppningsvis ocks&aring; b&auml;ttre f&ouml;rst&aring; hur DNS, domain name  system, fungerar. N&auml;r en dom&auml;n (&auml;ven kallad zon) skickas till DNSCheck s&aring;  kommer programmet att unders&ouml;ka dom&auml;nens h&auml;lsotillst&aring;nd genom att g&aring; igenom DNS  fr&aring;n roten (.) till TLD:n (toppdom&auml;nen, till exempel .SE) och till slut de  DNS-servrar som inneh&aring;ller information om den specificerade dom&auml;nen (till  exempel iis.se). DNSCheck utf&ouml;r &auml;ven en hel del andra test, s&aring; som att  kontrollera DNSSEC-signaturer, att de olika v&auml;rdarna g&aring;r att komma &aring;t och att  IP-adresser &auml;r giltiga.</p>",
			"Om domain name system, DNS",
			"<p>Domain name system (f&ouml;rkortat DNS) skulle kunna kallas  Internets &rdquo;telefonbok&rdquo;. Det ser till att l&auml;sbara namn p&aring; webbsidor (som www.iis.se) kan &ouml;vers&auml;ttas till de mer  sv&aring;rbegripliga IP-adresser som datorerna beh&ouml;ver f&ouml;r att kommunicera med  varandra (i detta fall 212.247.7.229).</p><p>F&ouml;rutom att l&aring;ta dig surfa p&aring; Internet med din webbl&auml;sare  med hj&auml;lp av namn p&aring; webbsidor ist&auml;llet f&ouml;r IP-adresser ser DNS &auml;ven till att  din e-post hittar r&auml;tt. Med andra ord, ett stabilt DNS &auml;r n&ouml;dv&auml;ndigt f&ouml;r att de  flesta f&ouml;retag ska kunna fungera och arbeta effektivt.</p>",
			"Vanliga fr&aring;gor om DNSCheck",
			'<h5 id="findex">Index</h5> 
			<ol>

				<li><a href="#f1">Vad &auml;r DNSCheck?</a></li>
				<li><a href="#f2">Vad &auml;r DNS?</a></li>
				<li><a href="#f3">Vad h&auml;nder med www.dnscheck.se?</a></li>
				<li><a href="#f4">Varf&ouml;r en ny DNSCheck?</a></li>
				<li><a href="#f5">Hur fungerar DNSCheck?</a></li>
				<li><a href="#f6">Hur kan DNSCheck hj&auml;lpa mig?</a></li>
				<li><a href="#f7">DNSCheck visar &rdquo;Fel&rdquo;/&rdquo;Varning&rdquo; f&ouml;r min dom&auml;n.  Vad inneb&auml;r det?</a></li>
				<li><a href="#f8">Hur kan DNSCheck bed&ouml;ma vad som &auml;r r&auml;tt och fel?</a></li>
				<li><a href="#f9">Hanterar DNSCheck IPv6?</a></li>
				<li><a href="#f10">Hanterar DNSCheck DNSSEC?</a></li>
				<li><a href="#f11">Vad skiljer DNSCheck fr&aring;n annan mjukvara som  testar zoner?</a></li>
				<li><a href="#f12">Fungerar DNSCheck f&ouml;r dom&auml;nnamn som inte slutar  med .se?</a></li>
				<li><a href="#f13">DNSCheck och personlig integritet</a></li>
				<li><a href="#f14">Varf&ouml;r kan jag inte testa min dom&auml;n?</a></li>
				<li><a href="#f15">Vilka slags anrop genereras av DNSCheck?</a></li>

			</ol>
			<div class="divider"></div>

			<h5 id="f1">Vad &auml;r DNSCheck?</h5>

			<p>DNSCheck &auml;r ett program designat f&ouml;r att hj&auml;lpa m&auml;nniskor  att kontrollera, m&auml;ta och f&ouml;rhoppningsvis ocks&aring; b&auml;ttre f&ouml;rst&aring; hur DNS, domain  name system, fungerar. N&auml;r en dom&auml;n (&auml;ven kallad zon) skickas till DNSCheck s&aring;  kommer programmet att unders&ouml;ka dom&auml;nens h&auml;lsotillst&aring;nd genom att g&aring; igenom DNS  fr&aring;n roten (.) till TLD:n (toppdom&auml;nen, till exempel .SE) och till slut de  DNS-servrar som inneh&aring;ller information om den specificerade dom&auml;nen (till  exempel iis.se). DNSCheck utf&ouml;r &auml;ven en hel del andra test, s&aring; som att  kontrollera DNSSEC-signaturer, att de olika v&auml;rdarna g&aring;r att komma &aring;t och att  IP-adresser &auml;r giltiga.</p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f2">Vad &auml;r DNS?</h5>

			<p>Domain name system (f&ouml;rkortat DNS) skulle kunna kallas  Internets &rdquo;telefonbok&rdquo;. Det ser till att l&auml;sbara namn p&aring; webbsidor (som www.iis.se) kan &ouml;vers&auml;ttas till de mer  sv&aring;rbegripliga IP-adresser som datorerna beh&ouml;ver f&ouml;r att kommunicera med  varandra (i detta fall 212.247.7.229).</p>
			<p>F&ouml;rutom att l&aring;ta dig surfa p&aring; Internet med din webbl&auml;sare  med hj&auml;lp av namn p&aring; webbsidor ist&auml;llet f&ouml;r IP-adresser ser DNS &auml;ven till att  din e-post hittar r&auml;tt. Med andra ord, ett stabilt DNS &auml;r n&ouml;dv&auml;ndigt f&ouml;r att de  flesta f&ouml;retag ska kunna fungera och arbeta effektivt.</p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f3">Vad h&auml;nder med www.dnscheck.se?</h5>

			<p>Webbadressen <a href="http://www.dnscheck.se">www.dnscheck.se</a> pekar till en tidigare version av DNSCheck som .SE utvecklade tillsammans med  Patrik F&auml;ltstr&ouml;m fr&aring;n Frobbit AB. Den nya versionen av DNSCheck ligger p&aring;  <a href="http://dnscheck.iis.se">dnscheck.iis.se</a> och utvecklades av Jakob Schlyter fr&aring;n Kirei AB.</p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f4">Varf&ouml;r en ny  DNSCheck?</h5>

			<p>.SE ville ha mer kontroll &ouml;ver koden och kunna &aring;teranv&auml;nda  delar av DNSCheck-koden i andra projekt. Vi kom s&aring;ledes till slutsatsen att det  var b&auml;ttre att b&ouml;rja om fr&aring;n grunden och bygga en modul&auml;r kodbas som vi ocks&aring;  kunde ut&ouml;ka med ny funktionalitet, till exempel IPv6- och DNSSEC-tester.</p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f5">Hur fungerar  DNSCheck?</h5>

			<p>Om du vill ha den tekniska informationen om hur DNSCheck  fungerar r&aring;der vi dig att kolla den wiki/trac som &auml;r kopplad till  DNSCheck-projektet (som &auml;r &ouml;ppen k&auml;llkod). Du hittar den p&aring; f&ouml;rljande URL: <a href="http://opensource.iis.se/trac/dnscheck/wiki/Architecture">http://opensource.iis.se/trac/dnscheck/wiki/Architecture</a>. Om du &auml;r ute efter ett mindre tekniskt svar b&ouml;r du f&ouml;rst l&auml;sa svaret till fr&aring;gan &quot;Vad &auml;r DNSCheck&quot; p&aring; denna sida.</p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f6">Hur  kan DNSCheck hj&auml;lpa mig?</h5>

			<p>Den nuvarande versionen av DNSCheck &auml;r avsedd f&ouml;r tekniker  eller &aring;tminstone de som &auml;r intresserade av att l&auml;ra sig mer om hur DNS  fungerar. Om du enbart vill l&aring;ta den som &auml;r ansvarig f&ouml;r din dom&auml;n (tech-c  eller teknisk personal hos din DNS-leverant&ouml;r) veta att det finns problem med  din dom&auml;n kan du anv&auml;nda l&auml;nken som finns l&auml;ngst ner p&aring; resultatsidan efter att  ett test utf&ouml;rts. Om du har k&ouml;rt ett test kan du s&aring;ledes l&auml;nka till just det  specifika testresultatet genom att kopiera l&auml;nken som d&aring; finns l&auml;ngst ner p&aring;  sidan. Till exempel, l&auml;nken h&auml;r nedanf&ouml;r pekar p&aring; ett tidigare utf&ouml;rt test av  &rdquo;iis.se&rdquo;:<br />
  <a href="http://dnscheck.iis.se/?time=1220357126&amp;id=66&amp;view=basic">http://dnscheck.iis.se/?time=1220357126&amp;id=66&amp;view=basic </a></p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f7">DNSCheck visar  &rdquo;Fel&rdquo;/&rdquo;Varning&rdquo; f&ouml;r min dom&auml;n. Vad inneb&auml;r det?</h5>

			<p>Det beror p&aring; vilket test det g&auml;ller. I de flesta fall kan du  klicka p&aring; fel- eller varningsmeddelandet f&ouml;r att f&aring; mer information om vad det  var f&ouml;r problem.</p>
			<p>Till exempel, om vi skulle testa dom&auml;nen &rdquo;iis.se&rdquo; och f&aring; ett  felmeddelande som s&auml;ger <strong>&rdquo;DNS-servern  ns.nic.se (212.247.7.228) svarar inte p&aring; anrop &ouml;ver UDP&rdquo;</strong>. Vad inneb&auml;r  detta? Efter att vi klickar p&aring; meddelandet f&aring;r vi mer detaljerad information. I  det h&auml;r fallet: <strong>&rdquo;DNS-servern svarade  inte p&aring; anrop &ouml;ver UDP. Detta beror troligtvis p&aring; att DNS-servern inte &auml;r  korrekt uppsatt eller en felaktigt konfigurerad brandv&auml;gg.&rdquo;</strong> Lyckligtvis var  detta bara ett exempel eftersom det d&auml;r felet i praktiken betyder att en  DNS-server &auml;r otillg&auml;nglig, s&aring; det &auml;r inte direkt ett harml&ouml;st fel.</p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f8">Hur kan DNSCheck  bed&ouml;ma vad som &auml;r r&auml;tt och fel?</h5>

			<p>Ingen kan ge ett definitivt, slutgiltigt utl&aring;tande om en  dom&auml;ns h&auml;lsa. Detta &auml;r viktigt att po&auml;ngtera. .SE och m&auml;nniskorna bakom  DNSCheck p&aring;st&aring;r inte att DNSCheck alltid har helt r&auml;tt. I vissa fall g&aring;r  &aring;sikter is&auml;r, speciellt mellan olika l&auml;nder, men ibland &auml;ven lokalt. Vi har  haft turen att ha hj&auml;lp av en extremt kompetent grupp DNS-experter h&auml;r i  Sverige. Vi hoppas att deras &aring;sikter i kombination med v&aring;ra egna har resulterat  i en bra kompromiss mellan vad som &auml;r potentiellt farliga fel och vad som bara  beh&ouml;ver en varning eller en anm&auml;rkning.</p>
			<p>Eftersom DNS utvecklas hela tiden kan situationer som idag  bara kr&auml;ver en varning r&auml;knas som riktiga fel imorgon. Om du tror du hittat  n&aring;got som vi felbed&ouml;mt, tveka d&aring; inte att kontakta oss p&aring; <a href="mailto:dnscheck@iis.se">dnscheck@iis.se</a> med en l&auml;nk till ditt test  och en f&ouml;rklaring av varf&ouml;r du anser att resultatet inte &auml;r korrekt. (Hur man  l&auml;nkar till ett test hittar du i &rdquo;Hur kan DNSCheck hj&auml;lpa mig?&rdquo;-delen av denna  FAQ.)</p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f9">Hanterar DNSCheck  IPv6?</h5>

			<p>Ja, fast eftersom .SE f&ouml;r n&auml;rvarande inte har st&ouml;d f&ouml;r IPv6  kan vi inte utf&ouml;ra dessa test. S&aring; snart vi har IPv6-st&ouml;d f&auml;rdigt kommer vi att  testa IPv6 p&aring; samma s&auml;tt som IPv4 testas av DNSCheck idag.</p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f10">Hanterar DNSCheck  DNSSEC?</h5>

			<p>Ja. Om DNSSEC &auml;r tillg&auml;ngligt f&ouml;r en dom&auml;n som testas av  DNSCheck s&aring; kommer detta att testas automatiskt.</p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f11">Vad skiljer DNSCheck  fr&aring;n annan mjukvara som testar zoner?</h5>

			<p>F&ouml;rst och fr&auml;mst sparar DNSCheck all testhistoria. Det  inneb&auml;r att du kan g&aring; tillbaka och titta p&aring; ett test du gjorde f&ouml;r en vecka  sedan och j&auml;mf&ouml;ra det med ett test du nyss gjorde.</p>
			<p>DNSCheck kontrollerar &auml;ven att en zons tidigare anv&auml;nda  (f&ouml;re detta) DNS-servrar inte l&auml;ngre inneh&aring;ller information om zonen du testar.  (Detta g&auml;ller enbart f&ouml;r .SE-dom&auml;ner som &auml;r ompekade efter februari 2007.)</p>
			<p>DNSCheck f&ouml;rs&ouml;ker ocks&aring; f&ouml;rklara fel och varningar p&aring; ett  tydligt s&auml;tt, &auml;ven om dessa meddelanden kan vara sv&aring;ra att f&ouml;rst&aring; f&ouml;r en  icke-tekniker. N&auml;sta version av DNSCheck, som kommer att lanseras senare detta  &aring;r, kommer att vara mer informativ f&ouml;r mindre tekniska anv&auml;ndare.</p>
			<p>DNSCheck kollar kontinuerligt igenom .SE-zonen och  rapporterar in dess h&auml;lsa till databasen.</p>
			<p>Det finns en &rdquo;avancerad&rdquo; flik tillg&auml;nglig f&ouml;r de tekniker  som f&ouml;redrar mer detaljerad testinformation.</p>
			<p>Den h&auml;r versionen av DNSCheck &auml;r &ouml;ppen k&auml;llkod och &auml;r  modul&auml;rt uppbyggd. Du kan med andra ord &aring;teranv&auml;nda delar av koden i dina egna  system om du vill.</p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f12">Fungerar DNSCheck f&ouml;r  dom&auml;nnamn som inte slutar med .se?</h5>

			<p>Ja. Alla test som utf&ouml;rs p&aring; .SE-dom&auml;ner kommer utf&ouml;ras p&aring;  din zon ocks&aring;. Det som inte g&ouml;rs f&ouml;r andra dom&auml;ner &auml;n .SE &auml;r dock den  periodiska, automatiska genomg&aring;ngen av alla dom&auml;ner i zonen som vi utf&ouml;r. Allt  annat fungerar exakt likadant.</p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f13">DNSCheck och personlig  integritet</h5>

                        <p>Eftersom DNSCheck &auml;r tillg&auml;nglig f&ouml;r alla &auml;r det ocks&aring; m&ouml;jligt  f&ouml;r vem som helst att kontrollera din dom&auml;n och ocks&aring; se testhistoria f&ouml;r din  dom&auml;n. Det finns dock inget s&auml;tt att se vem som har gjort ett test eftersom det  enda som loggas &auml;r tidpunken d&aring; testet gjordes.</p>
                        <p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>

			<h5 id="f14">Varf&ouml;r kan jag inte  testa min dom&auml;n?</h5>
                        
			<p>Om vi utg&aring;r fr&aring;n att dom&auml;nen du f&ouml;rs&ouml;ker testa faktiskt  existerar s&aring; finns det tv&aring; saker som kan orsaka detta:</p>
			<p>1. F&ouml;r att f&ouml;rhindra att flera test g&ouml;rs samtidigt  p&aring; samma zon fr&aring;n samma IP-adress finns det en p&aring;tvingad f&ouml;rdr&ouml;jning p&aring; 5  minuter mellan identiska test. Detta inneb&auml;r att du inte kan testa en dom&auml;n  oftare &auml;n var 5:e minut. Om du testar din dom&auml;n igen innan 5 minuter f&ouml;rflutit  s&aring; visas det senast sparade resultatet.</p>
			<p>2. Eftersom DNSCheck &auml;r designad f&ouml;r att testa  dom&auml;ner (som iis.se) och inte v&auml;rdnamn i en dom&auml;n (som www.iis.se) kontrollerar DNSChecks webbsida  dom&auml;nen du skrivit in innan den skickas vidare till DNSChecks testmotor f&ouml;r att  se att det verkligen &auml;r en dom&auml;n. Denna kontroll kan i vissa s&auml;llsynta fall  misslyckas (och zonen s&aring;ledes inte godk&auml;nns som korrekt). De enda g&aring;nger vi  sett detta h&auml;nda &auml;r ifall de DNS-servrar som tillh&ouml;r den zon du f&ouml;rs&ouml;ker testa  &auml;r v&auml;ldigt trasiga. H&ouml;r g&auml;rna av dig ifall detta h&auml;nt dig s&aring; vi f&aring;r mer  information om hur vi kan korrigera hur detta test av dom&auml;nen utf&ouml;rs. Det h&auml;r testet  kommer att f&ouml;rb&auml;ttras, det lovar vi.</p>

                        <p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>
			
			<h5 id="f15">Vilka slags anrop genereras av DNSCheck?</h5>

			<p>Det h&auml;r &auml;r en sv&aring;r fr&aring;ga att svara p&aring; eftersom DNSCheck  kommer att generera olika typer av anrop beroende p&aring; hur dina DNS-servrar  svarar. Det enklaste s&auml;ttet att se exakt vad DNSCheck testar &auml;r att k&ouml;ra  &rdquo;dnscheck&rdquo; CLI-kommandot och l&auml;gga till flaggan &rdquo;--raw&rdquo;. Resultatet ger  grundlig information om vad som h&auml;nder under testet. Det b&ouml;r dock n&auml;mnas att  utmatningen fr&aring;n CLI-verktyget &auml;r v&auml;ldigt tekniskt utmanande s&aring; ifall du inte  gillar bits och bytes kanske du vill undvika det.</p>
			<p><a href="#findex">Tillbaka till b&ouml;rjan</a></p>',
			"F&ouml;rklaring",
			"Testet var ok",
			"Testet inneh&ouml;ll varningar",
			"Testet inneh&ouml;ll fel",
			"Testet utf&ouml;rdes inte"
		)
	);
	
	
	function translate($translateString)
	{
		global $languageId;
		global $translationMap;
		global $translationIndex;
		
		if (!isset($translationMap[$languageId]))
		{
			return $translateString;
		}
		
		$index = array_search($translateString, $translationIndex);
		if (false === $index)
		{
			return $translateString;
		}
		
		if ((!isset($translationMap[$languageId][$index])) || (is_null($translationMap[$languageId][$index])))
		{
			return $translateString;
		}
		
		return $translationMap[$languageId][$index];
	}
?>
