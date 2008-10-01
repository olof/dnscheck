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
		"Test was not performed",
		"Delegation",
		"Nameserver",
		"Consistency",
		"SOA",
		"Connectivity",
		"DNSSEC",
		"Link to this test"
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
			"The domain you provided doesn't seem to be delegated or was entered incorrectly. You need to enter only the domain name, like ”iis.se”, not the name of a subdomain, like ”dev.iis.se” or a webserver like ”www.iis.se”.",
			"Loading",
			"Waiting for the test results to be loaded",
			"All tests are ok",
			"Warnings found in test",
			"Errors found in test",
			"About DNSCheck",
			"<img src='_img/img_trafficlight.png' alt='Trafficlight' class='right' /><p>DNSCheck is a program that was designed to help people check, measure and hopefully also understand the workings of the Domain Name System, DNS. When a domain (aka zone) is submitted to DNSCheck it will investigate the domain's general health by traversing the DNS from root (.) to the TLD (Top Level Domain, like .SE) to eventually the nameserver(s) that holds the information about the specified domain (like iis.se). Some other sanity checks, for example measuring host connectivity, validity of IP-addresses and control of DNSSEC signatures will also be performed.</p>",
			"About the domain name system, DNS",
			"<p>The domain name system (DNS in short) is what could be called the ”phone book” of the Internet. It keeps track of the mapping of, for example, a human-readable website name (like www.iis.se) to the slightly more arcane form of an IP-address that the computer needs to initiate communication (in this case 212.247.7.229). </p><p>Besides browsing the Internet with your web browser using website names instead of IP-addresses the DNS also makes sure your emails find their way. In short, a stable DNS is vital for most companies to maintain a working and efficient operation.</p>",
			"DNSCheck FAQ",
			'<h5 id="findex">Index</h5> 
			<ol>

				<li><a href="#f1">What is DNSCheck?</a></li>
				<li><a href="#f2">What is DNS?</a></li>
				<li><a href="#f3">What about www.dnscheck.se?</a></li>
				<li><a href="#f4">Why a new DNSCheck?</a></li>
				<li><a href="#f5">How does DNSCheck work?</a></li>
				<li><a href="#f6">How can DNSCheck help me?</a></li>
				<li><a href="#f7">DNSCheck goes ”Error”/”Warning” on my domain, what does it mean?</a></li>
				<li><a href="#f8">How can DNSCheck judge what is right and wrong?</a></li>
				<li><a href="#f9">Does DNSCheck handle IPv6?</a></li>
				<li><a href="#f10">Does DNSCheck handle DNSSEC?</a></li>
				<li><a href="#f11">What makes DNSCheck differ from other zone controlling software?</a></li>
				<li><a href="#f12">Will DNSCheck work for my non-.se-domain?</a></li>
				<li><a href="#f13">DNSCheck and privacy</a></li>
				<li><a href="#f14">How come I can’t test my domain?</a></li>
				<li><a href="#f15">What kind of queries does DNSCheck generate?</a></li>

			</ol>
			<div class="divider"></div>

			<h5 id="f1">What is DNSCheck?</h5>

			<p>DNSCheck is a program that was designed to help people check, measure and hopefully also understand the workings of the Domain Name System, DNS. When a domain (aka zone) is submitted to DNSCheck it will investigate the domain’s general health by traversing the DNS from root (.) to the TLD (Top Level Domain, like .SE) to eventually the nameserver(s) that holds the information about the specified domain (like iis.se). Some other sanity checks, for example measuring host connectivity, validity of IP-addresses and control of DNSSEC signatures will also be performed. </p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f2">What is DNS?</h5>

			<p>The domain name system (DNS in short) is what could be called the “phone book” of the Internet. It keeps track of the mapping of, for example, a human-readable website name (like www.iis.se) to the slightly more arcane form of an IP-address that the computer needs to initiate communication (in this case 212.247.7.229). <br />
	        Besides browsing the Internet with your web browser using website names instead of IP-addresses the DNS also makes sure your emails find their way to the right recipient. In short, a stable DNS is vital for most companies to maintain a working and efficient operation.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f3">What about www.dnscheck.se?</h5>

			<p>The webpage <a href="http://www.dnscheck.se">www.dnscheck.se</a> points to an earlier version of DNSCheck that .SE developed with the help of Patrik Fältsröm of Frobbit AB. The new version of DNSCheck resides in <a href="http://dnscheck.iis.se">dnscheck.iis.se</a> and was developed by Jakob Schlyter of Kirei AB.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f4">Why a new DNSCheck?</h5>

			<p>.SE wanted a better control of the code and also the ability to reuse parts of the DNSCheck code in other projects. Thus we came to the conclusion that it was a better idea to start from scratch and build a modular codebase that we could also add new features to, like for example ipv6- and dnssec-controls.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f5">How does DNSCheck work?</h5>

			<p>If you want the technical information about how DNSCheck operates you are advised to check the wiki/trac connected to the DNSCheck open source project. This is the URL: <a href="http://opensource.iis.se/trac/dnscheck/wiki/Architecture">http://opensource.iis.se/trac/dnscheck/wiki/Architecture</a> . If you want a less technical answer you should check the first FAQ-question: “What is DNSCheck”.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f6">How can DNSCheck help me?</h5>

			<p>The current version of DNSCheck was made for technicians or at least people who are interested to learn more about how the DNS operates. If you merely want to show whoever is in charge of your domain (the tech-c or technical staff at your name server provider) that there in fact is a problem with your domain you can use the link that appears on the bottom of the page after each test. So if you have run a test and want to show someone the result of that specific test you can just copy the link at the bottom of the page that displays your test results. The link below, for example, points at a previous test on "iis.se":</p> <p> <a href="http://dnscheck.iis.se/?time=1220357126&id=66&view=basic">http://dnscheck.iis.se/?time=1220357126&id=66&view=basic </p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f7">DNSCheck goes ”Error”/”Warning” on my domain, what does it mean?</h5>

			<p>Of course, this depends on what kind of test failed for your zone. In most cases you can press the actual error/warning-message and in so doing get more detailed information about what kind of problem that was found.</p>
			<p>As an example if we test the domain "iis.se" and recieve an error titled “<strong>Name server ns.nic.se (212.247.7.228) does not answer queries over UDP</strong>”. What does this mean? After we click this message more detailed information become visible. More specific this: “<strong>The name server failed to answer queries sent over UDP. This is probably due to the name server not correctly set up or due to misconfigured filtering in a firewall.</strong>”. Luckily this was just an example, that error basically means the name server is down so it’s not the most harmless error around. </p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f8">How can DNSCheck judge what is right and wrong?</h5>

			<p>There is no  final judgement of the health of a domain that can be bestowed by anyone. This  is very important. .SE and the people behind DNSCheck do not claim that  DNSCheck is correct in every aspect. Sometimes opinions differ, especially  between countries, but sometimes also locally. We have had the luck to have the  help of an extremely competent DNS-group here in Sweden. Hopefully their opinions in  combination with ours have made a good compromise between what is an actual  potentially dangerous error and what could be merely seen as a notice or  warning.</p>
			<p>But as with  all things as evolving as DNS the situation is most likely changing, what is a  notice today could be an error tomorrow. If you really think we’ve made a  mistake in our judgement please don’t hesitate to drop us an email at <a href="mailto:dnscheck@iis.se">dnscheck@iis.se</a> with a link to your test and an explanation why you think it shows something that you consider incorrect. ( If you don’t know how to find the link to your test, check the "How can DNSCheck help me"-part of this FAQ ).</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f9">Does DNSCheck handle IPv6?</h5>

			<p>Yes, it  does. However, since .SE currently doesn’t have IPv6-connectivity these tests  cannot be performed. As soon as IPv6-connectivity is established we will test  IPv6 in the same way we test IPv4.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f10">Does DNSCheck handle DNSSEC?</h5>

			<p>Yes, if  DNSSEC is available on a domain that is sent to DNSCheck it will be checked  automatically.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f11">What makes DNSCheck differ from other zone controlling software?</h5>

			<p>First of  all this DNSCheck saves all history from earlier tests, which means you can go  back to a test you did a week ago and compare it to the test you ran a moment  ago.<br />
			<br />
			DNSCheck also controls that the name servers a zone has used previously no longer  contains information about the zone you’re testing (this only applies to  .SE-domains that have been redelegated after February 2007). </p>
			<p>DNSCheck  will also try and explain the error/warning to you in a good way, although these  messages can be difficult to understand for a non-technician. The next version  of DNSCheck, that will be launched later this year, will be more compliant to  non-technician users.</p>
			<p>DNSCheck  will continuously scan the .SE-zone and report its health into the database.</p>
			<p>There’s an  “advanced” tab for technicians who might want to use DNSCheck without the “basic” view.</p>
			<p>Lastly, this  open source version of DNSCheck was built using modular code which, basically,  means you can use parts of it in your systems, if you’d want to. It’s quite  rare that you’d want a complete program just to check for example redelegations.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f12">Will DNSCheck work for my non-.se-domain?</h5>

			<p>Yes. All  the checks that occur for .SE-domains will be used on your zone as well.  However, the periodic sweep of the database (automatic checks basically) only  happens on .SE-domains, other than that it’s identical.</p>
			<p><a href="#findex">Back to the top </a></p>

			<h5 id="f13">DNSCheck and privacy</h5>

                        <p>Since DNSCheck is open to everyone it is possible for anyone to check your domain and also see history from previous tests, however there is no way to tell who has run a specific test since nothing is logged except the time of the test.    </p>
                        <p><a href="#findex">Back to the top </a></p>

			<h5 id="f14">How come I can’t test my domain?</h5>
                        
                        <p>If we skip the situation where the domain doesn’t exist, as in you input a non-existing domain to DNSCheck, there are 2 other possibilites:  <br />
                        <br />

			1. To protect the engine from multiple identical inputs, that is the same IP checking the same zone several times, there is a delay of 5 minutes between identical subsequent tests. Which practically means that you can only test the same domain once every 5 minutes, if you try and test it again within 5 minutes the last results will be displayed instead.</p>
			
			 <p>2. Because DNSCheck was made to check domains (like iis.se) and not hostnames in a domain (like www.iis.se) the DNSCheck webpage will do a pre-control of your domain before it sends it on to the engine for testing. This shouldn’t effect the great majority of domains out there but it CAN do so, because if the webpage decides a domain doesn’t exist the check wont run. Sofar the only time we’ve seen this is when a domains’ nameservers all lie within the domain that’s being tested and these are very broken. We need to fix this, and please do report if you cannot check your domain so that we can see if anything else is wrong. This control will be improved, that’s a promise.</p>

                        <p><a href="#findex">Back to the top </a></p>
			
			<h5 id="f15">What kind of queries does DNSCheck generate?</h5>

			<p>This  question is very hard to answer since DNSCheck will generate different queries  depending on how your name servers answer. The easiest way to get a full view  of what queries and results are generated is to run the “dnscheck” CLI command  and add the flag “--raw”. This will result in quite thorough information on  what is happening. However the output from this CLI-tool is quite heavily  technical so unless you’re into bits and bytes you might want to skip this  step. :)</p>
			<p><a href="#findex">Back to the top </a></p>',
			"Explanation",
			"Test was ok",
			"Test contains warnings",
			"Test contains errors",
			"Test was not performed",
			"Delegation",
			"Nameserver",
			"Consistency",
			"SOA",
			"Connectivity",
			"DNSSEC",
			"Link to this test"
		),
		"se" => array(
			"Hem",
			"Vanliga frågor",
			"En tjänst från .SE",
			"Testa din DNS-server och upptäck fel",
			"Ange ditt domännamn nedan för att testa dess DNS-servrar.",
			"Testa nu",
			"Förenklat resultat",
			"Avancerat resultat",
			"Tidigare test",
			"Historiken kunde ej laddas",
			"Ingen historik finns",
			"Sida",
			".SE (Stiftelsen för Internetinfrastruktur)",
			"Domänen finns inte",
			"Domänen du angav verkar inte vara registrerad",
			"Laddar",
			"Väntar på testresultat",
			"Alla test är ok",
			"Testet innehöll varningar",
			"Testet innehöll fel",
			"Om DNSCheck",
			"<img src='_img/img_trafficlight.png' alt='Trafficlight' class='right' /><p>DNSCheck är ett program designat för att hjälpa människor  att kontrollera, mäta och förhoppningsvis också bättre förstå hur DNS, domain name  system, fungerar. När en domän (även kallad zon) skickas till DNSCheck så  kommer programmet att undersöka domänens hälsotillstånd genom att gå igenom DNS  från roten (.) till TLD:n (toppdomänen, till exempel .SE) och till slut de  DNS-servrar som innehåller information om den specificerade domänen (till  exempel iis.se). DNSCheck utför även en hel del andra test, så som att  kontrollera DNSSEC-signaturer, att de olika värdarna går att komma åt och att  IP-adresser är giltiga.</p>",
			"Om domain name system, DNS",
			"<p>Domain name system (förkortat DNS) skulle kunna kallas  Internets ”telefonbok”. Det ser till att läsbara namn på webbsidor (som www.iis.se) kan översättas till de mer  svårbegripliga IP-adresser som datorerna behöver för att kommunicera med  varandra (i detta fall 212.247.7.229).</p><p>Förutom att låta dig surfa på Internet med din webbläsare  med hjälp av namn på webbsidor istället för IP-adresser ser DNS även till att  din e-post hittar rätt. Med andra ord, ett stabilt DNS är nödvändigt för att de  flesta företag ska kunna fungera och arbeta effektivt.</p>",
			"Vanliga frågor om DNSCheck",
			'<h5 id="findex">Index</h5> 
			<ol>

				<li><a href="#f1">Vad är DNSCheck?</a></li>
				<li><a href="#f2">Vad är DNS?</a></li>
				<li><a href="#f3">Vad händer med www.dnscheck.se?</a></li>
				<li><a href="#f4">Varför en ny DNSCheck?</a></li>
				<li><a href="#f5">Hur fungerar DNSCheck?</a></li>
				<li><a href="#f6">Hur kan DNSCheck hjälpa mig?</a></li>
				<li><a href="#f7">DNSCheck visar ”Fel”/”Varning” för min domän.  Vad innebär det?</a></li>
				<li><a href="#f8">Hur kan DNSCheck bedöma vad som är rätt och fel?</a></li>
				<li><a href="#f9">Hanterar DNSCheck IPv6?</a></li>
				<li><a href="#f10">Hanterar DNSCheck DNSSEC?</a></li>
				<li><a href="#f11">Vad skiljer DNSCheck från annan mjukvara som  testar zoner?</a></li>
				<li><a href="#f12">Fungerar DNSCheck för domännamn som inte slutar  med .se?</a></li>
				<li><a href="#f13">DNSCheck och personlig integritet</a></li>
				<li><a href="#f14">Varför kan jag inte testa min domän?</a></li>
				<li><a href="#f15">Vilka slags anrop genereras av DNSCheck?</a></li>

			</ol>
			<div class="divider"></div>

			<h5 id="f1">Vad är DNSCheck?</h5>

			<p>DNSCheck är ett program designat för att hjälpa människor  att kontrollera, mäta och förhoppningsvis också bättre förstå hur DNS, domain  name system, fungerar. När en domän (även kallad zon) skickas till DNSCheck så  kommer programmet att undersöka domänens hälsotillstånd genom att gå igenom DNS  från roten (.) till TLD:n (toppdomänen, till exempel .SE) och till slut de  DNS-servrar som innehåller information om den specificerade domänen (till  exempel iis.se). DNSCheck utför även en hel del andra test, så som att  kontrollera DNSSEC-signaturer, att de olika värdarna går att komma åt och att  IP-adresser är giltiga.</p>
			<p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f2">Vad är DNS?</h5>

			<p>Domain name system (förkortat DNS) skulle kunna kallas  Internets ”telefonbok”. Det ser till att läsbara namn på webbsidor (som www.iis.se) kan översättas till de mer  svårbegripliga IP-adresser som datorerna behöver för att kommunicera med  varandra (i detta fall 212.247.7.229).</p>
			<p>Förutom att låta dig surfa på Internet med din webbläsare  med hjälp av namn på webbsidor istället för IP-adresser ser DNS även till att  din e-post hittar rätt. Med andra ord, ett stabilt DNS är nödvändigt för att de  flesta företag ska kunna fungera och arbeta effektivt.</p>
			<p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f3">Vad händer med www.dnscheck.se?</h5>

			<p>Webbadressen <a href="http://www.dnscheck.se">www.dnscheck.se</a> pekar till en tidigare version av DNSCheck som .SE utvecklade tillsammans med  Patrik Fältström från Frobbit AB. Den nya versionen av DNSCheck ligger på  <a href="http://dnscheck.iis.se">dnscheck.iis.se</a> och utvecklades av Jakob Schlyter från Kirei AB.</p>
			<p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f4">Varför en ny  DNSCheck?</h5>

			<p>.SE ville ha mer kontroll över koden och kunna återanvända  delar av DNSCheck-koden i andra projekt. Vi kom således till slutsatsen att det  var bättre att börja om från grunden och bygga en modulär kodbas som vi också  kunde utöka med ny funktionalitet, till exempel IPv6- och DNSSEC-tester.</p>
			<p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f5">Hur fungerar  DNSCheck?</h5>

			<p>Om du vill ha den tekniska informationen om hur DNSCheck  fungerar råder vi dig att kolla den wiki/trac som är kopplad till  DNSCheck-projektet (som är öppen källkod). Du hittar den på förljande URL: <a href="http://opensource.iis.se/trac/dnscheck/wiki/Architecture">http://opensource.iis.se/trac/dnscheck/wiki/Architecture</a>. Om du är ute efter ett mindre tekniskt svar bör du först läsa svaret till frågan ”Vad är DNSCheck” på denna sida.</p>
			<p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f6">Hur  kan DNSCheck hjälpa mig?</h5>

			<p>Den nuvarande versionen av DNSCheck är avsedd för tekniker  eller åtminstone de som är intresserade av att lära sig mer om hur DNS  fungerar. Om du enbart vill låta den som är ansvarig för din domän (tech-c  eller teknisk personal hos din DNS-leverantör) veta att det finns problem med  din domän kan du använda länken som finns längst ner på resultatsidan efter att  ett test utförts. Om du har kört ett test kan du således länka till just det  specifika testresultatet genom att kopiera länken som då finns längst ner på  sidan. Till exempel, länken här nedanför pekar på ett tidigare utfört test av  ”iis.se”:<br />
  <a href="http://dnscheck.iis.se/?time=1220357126&amp;id=66&amp;view=basic">http://dnscheck.iis.se/?time=1220357126&amp;id=66&amp;view=basic </a></p>
			<p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f7">DNSCheck visar  ”Fel”/”Varning” för min domän. Vad innebär det?</h5>

			<p>Det beror på vilket test det gäller. I de flesta fall kan du  klicka på fel- eller varningsmeddelandet för att få mer information om vad det  var för problem.</p>
			<p>Till exempel, om vi skulle testa domänen ”iis.se” och få ett  felmeddelande som säger <strong>”DNS-servern  ns.nic.se (212.247.7.228) svarar inte på anrop över UDP”</strong>. Vad innebär  detta? Efter att vi klickar på meddelandet får vi mer detaljerad information. I  det här fallet: <strong>”DNS-servern svarade  inte på anrop över UDP. Detta beror troligtvis på att DNS-servern inte är  korrekt uppsatt eller en felaktigt konfigurerad brandvägg.”</strong> Lyckligtvis var  detta bara ett exempel eftersom det där felet i praktiken betyder att en  DNS-server är otillgänglig, så det är inte direkt ett harmlöst fel.</p>
			<p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f8">Hur kan DNSCheck  bedöma vad som är rätt och fel?</h5>

			<p>Ingen kan ge ett definitivt, slutgiltigt utlåtande om en  domäns hälsa. Detta är viktigt att poängtera. .SE och människorna bakom  DNSCheck påstår inte att DNSCheck alltid har helt rätt. I vissa fall går  åsikter isär, speciellt mellan olika länder, men ibland även lokalt. Vi har  haft turen att ha hjälp av en extremt kompetent grupp DNS-experter här i  Sverige. Vi hoppas att deras åsikter i kombination med våra egna har resulterat  i en bra kompromiss mellan vad som är potentiellt farliga fel och vad som bara  behöver en varning eller en anmärkning.</p>
			<p>Eftersom DNS utvecklas hela tiden kan situationer som idag  bara kräver en varning räknas som riktiga fel imorgon. Om du tror du hittat  något som vi felbedömt, tveka då inte att kontakta oss på <a href="mailto:dnscheck@iis.se">dnscheck@iis.se</a> med en länk till ditt test  och en förklaring av varför du anser att resultatet inte är korrekt. (Hur man  länkar till ett test hittar du i ”Hur kan DNSCheck hjälpa mig?”-delen av denna  FAQ.)</p>
			<p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f9">Hanterar DNSCheck  IPv6?</h5>

			<p>Ja, fast eftersom .SE för närvarande inte har stöd för IPv6  kan vi inte utföra dessa test. Så snart vi har IPv6-stöd färdigt kommer vi att  testa IPv6 på samma sätt som IPv4 testas av DNSCheck idag.</p>
			<p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f10">Hanterar DNSCheck  DNSSEC?</h5>

			<p>Ja. Om DNSSEC är tillgängligt för en domän som testas av  DNSCheck så kommer detta att testas automatiskt.</p>
			<p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f11">Vad skiljer DNSCheck  från annan mjukvara som testar zoner?</h5>

			<p>Först och främst sparar DNSCheck all testhistoria. Det  innebär att du kan gå tillbaka och titta på ett test du gjorde för en vecka  sedan och jämföra det med ett test du nyss gjorde.</p>
			<p>DNSCheck kontrollerar även att en zons tidigare använda  (före detta) DNS-servrar inte längre innehåller information om zonen du testar.  (Detta gäller enbart för .SE-domäner som är ompekade efter februari 2007.)</p>
			<p>DNSCheck försöker också förklara fel och varningar på ett  tydligt sätt, även om dessa meddelanden kan vara svåra att förstå för en  icke-tekniker. Nästa version av DNSCheck, som kommer att lanseras senare detta  år, kommer att vara mer informativ för mindre tekniska användare.</p>
			<p>DNSCheck kollar kontinuerligt igenom .SE-zonen och  rapporterar in dess hälsa till databasen.</p>
			<p>Det finns en ”avancerad” flik tillgänglig för de tekniker  som föredrar mer detaljerad testinformation.</p>
			<p>Den här versionen av DNSCheck är öppen källkod och är  modulärt uppbyggd. Du kan med andra ord återanvända delar av koden i dina egna  system om du vill.</p>
			<p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f12">Fungerar DNSCheck för  domännamn som inte slutar med .se?</h5>

			<p>Ja. Alla test som utförs på .SE-domäner kommer utföras på  din zon också. Det som inte görs för andra domäner än .SE är dock den  periodiska, automatiska genomgången av alla domäner i zonen som vi utför. Allt  annat fungerar exakt likadant.</p>
			<p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f13">DNSCheck och personlig  integritet</h5>

                        <p>Eftersom DNSCheck är tillgänglig för alla är det också möjligt  för vem som helst att kontrollera din domän och också se testhistoria för din  domän. Det finns dock inget sätt att se vem som har gjort ett test eftersom det  enda som loggas är tidpunken då testet gjordes.</p>
                        <p><a href="#findex">Tillbaka till början</a></p>

			<h5 id="f14">Varför kan jag inte  testa min domän?</h5>
                        
			<p>Om vi utgår från att domänen du försöker testa faktiskt  existerar så finns det två saker som kan orsaka detta:</p>
			<p>1. För att förhindra att flera test görs samtidigt  på samma zon från samma IP-adress finns det en påtvingad fördröjning på 5  minuter mellan identiska test. Detta innebär att du inte kan testa en domän  oftare än var 5:e minut. Om du testar din domän igen innan 5 minuter förflutit  så visas det senast sparade resultatet.</p>
			<p>2. Eftersom DNSCheck är designad för att testa  domäner (som iis.se) och inte värdnamn i en domän (som www.iis.se) kontrollerar DNSChecks webbsida  domänen du skrivit in innan den skickas vidare till DNSChecks testmotor för att  se att det verkligen är en domän. Denna kontroll kan i vissa sällsynta fall  misslyckas (och zonen således inte godkänns som korrekt). De enda gånger vi  sett detta hända är ifall de DNS-servrar som tillhör den zon du försöker testa  är väldigt trasiga. Hör gärna av dig ifall detta hänt dig så vi får mer  information om hur vi kan korrigera hur detta test av domänen utförs. Det här testet  kommer att förbättras, det lovar vi.</p>

                        <p><a href="#findex">Tillbaka till början</a></p>
			
			<h5 id="f15">Vilka slags anrop genereras av DNSCheck?</h5>

			<p>Det här är en svår fråga att svara på eftersom DNSCheck  kommer att generera olika typer av anrop beroende på hur dina DNS-servrar  svarar. Det enklaste sättet att se exakt vad DNSCheck testar är att köra  ”dnscheck” CLI-kommandot och lägga till flaggan ”--raw”. Resultatet ger  grundlig information om vad som händer under testet. Det bör dock nämnas att  utmatningen från CLI-verktyget är väldigt tekniskt utmanande så ifall du inte  gillar bits och bytes kanske du vill undvika det.</p>
			<p><a href="#findex">Tillbaka till början</a></p>',
			"Förklaring",
			"Testet var ok",
			"Testet innehöll varningar",
			"Testet innehöll fel",
			"Testet utfördes inte",
			"Delegering",
			"DNS-server",
			"Konsekventa inställningar",
			"SOA",
			"Uppkoppling",
			"DNSSEC",
			"Länk till det här testresultatet"
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
