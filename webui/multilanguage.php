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
			"Home",
			"FAQ",
			"En tj&auml;nst fr&aring;n .se",
			"Testa din DNS-server och uppt&auml;ck fel",
			"Ange ditt dom&auml;nnamn nedan s&aring; kommer vi att testa DNS-Servrarna som &auml;r kopplade till det.",
			"Testa nu",
			"F&ouml;renklat resultat",
			"Avancerat resultat",
			"Tidigare tester",
			"Historiken kunde ej laddas",
			"Ingen historik finns",
			"Sida",
			".SE (Stiftelsen f&ouml;r Internetinfrastruktur)",
			"Dom&auml;nen finns inte",
			"Dom&auml;nen du angav verkar inte vara registrerad",
			"Laddar",
			"V&auml;ntar p&aring; test resultat",
			"Alla test &auml;r ok",
			"Testet inneh&ouml;ll varningar",
			"Testet inneh&ouml;ll fel",
			"Om DNSCheck",
			"<p>DNSCheck info</p>",
			"Om domain name system, DNS",
			"<p>DNS info</p>",
			"DNSCheck FAQ",
			"<h5 id=\"findex\">Index</h5>",
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
