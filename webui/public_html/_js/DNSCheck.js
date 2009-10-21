	jQuery.fn.extend({
		copyEvents: function(from) {
			jQuery.event.copy(from, this);
			return this;
		},

		copyEventsTo: function(to) {
			jQuery.event.copy(this, to);
			return this;
		},

		cloneWithEvents: function(deep) {
			return this.clone( deep ).copyEvents( this );
		}
	});
	jQuery.event.copy = function(from, to) {
		from = (from.jquery) ? from : jQuery(from);
		to   = (to.jquery)   ? to   : jQuery(to);

		if (!from.size() || !from[0].events || !to.size()) return;

		var events = from[0].events;
		to.each(function() {
			for (var type in events)
				for (var handler in events[type])
					jQuery.event.add(this, type, events[type][handler], events[type][handler].data);
		});
	};
	/*
	 * END CopyEvents
	 *
	 */

	/**
	 * String trim
	 */
	String.prototype.trim = function() {
		var	str = this.replace(/^\s\s*/, ''),
			ws = /\s/,
			i = str.length;
		while (ws.test(str.charAt(--i)));
		return str.slice(0, i + 1);
	}
	/**
	 * End string trim
	 */

	var totalMillis = 0;
	var currentPage = 1;
	var totalPages = 5;
	var searchDomain = "";
	var groupId = 0;
	var getPagerXMLHTTPRequest = null;
	var getResultXMLHTTPRequest = null;
	var getResultTimeoutVar = null;

	function clearTree()
	{
		var treeDiv = $("#treediv")[0];
		while (0 < treeDiv.childNodes.length)
		{
			treeDiv.removeChild(treeDiv.childNodes[0]);
		}

		var listDiv = $("#listdiv")[0];
		while (0 < listDiv.childNodes.length)
		{
			listDiv.removeChild(listDiv.childNodes[0]);
		}

		groupId = 0;
	}

	function populateTree(tree, parentElement, collapsable)
	{
		for (var i = 0; i < tree.length; i++)
		{
			switch(tree[i].type)
			{
				case 0:
					var div = document.createElement("div");
					div.className = "maintest";

					var h4 = document.createElement("h4");
					h4.className = tree[i]['class'];

					if ((0 == tree[i].subtree.length) || (!collapsable))
					{
						h4.innerHTML = tree[i].caption;
					}
					else
					{
						groupId++;

						var a = document.createElement("a");
						a.href = "javascript:void(0);";
						a.className = "open";
						a.id = "group_" + groupId;
						a.innerHTML = tree[i].caption;

						a.onclick = function()
						{
							$("#" + this.id + "_result").slideToggle("slow");
							$("#" + this.id).toggleClass("open");
						}

						h4.appendChild(a);
					}

					div.appendChild(h4);
					parentElement.appendChild(div);

					if (0 < tree[i].subtree.length)
					{
						var innerDiv = document.createElement("div");
						innerDiv.id = "group_" + groupId + "_result";

						var innerUl = document.createElement("ul");
						innerUl.className = "subtests";
						innerDiv.appendChild(innerUl);

						parentElement.appendChild(innerDiv);
						populateTree(tree[i].subtree, innerUl, collapsable);
					}

					break;
				case 1:
				case 2:
				case 3:
					var li = document.createElement("li");
					if (1 == tree[i].type)
					{
						li.className = "subtestcat";
					}
					if (3 == tree[i].type)
					{
						li.className = "lev2";
					}

					var p = document.createElement("p");
					p.className = tree[i]['class'];
					li.appendChild(p);
					parentElement.appendChild(li);
					if (('undefined' == typeof(tree[i].description)) || (!collapsable))
					{
						p.innerHTML = tree[i].caption;
					}
					else
					{
						groupId++;

						var a = document.createElement("a");
						a.href = "javascript:void(0);";
						a.id = "group_" + groupId;
						a.innerHTML = tree[i].caption;

						a.onclick = function()
						{
							$("#" + this.id + "_description").slideToggle("slow");
							$("#" + this.id).toggleClass("open");
						}

						p.appendChild(a);

						var innerLi = document.createElement("li");
						if (2 == tree[i].type)
						{
							innerLi.className = "testinfo";
						}
						if (3 == tree[i].type)
						{
							innerLi.className = "testinfo2";
						}
						innerLi.id = a.id + "_description";
						innerLi.style.display = "none";

						var innerP = document.createElement("p");
						innerP.innerHTML = tree[i].description;
						innerLi.appendChild(innerP);

						parentElement.appendChild(innerLi);
					}


					populateTree(tree[i].subtree, parentElement, collapsable);
					break;
			}
		}
	}

	function refreshPager(pageNumber, callback)
	{
		document.getElementById("pagerlist").style.visibility = "hidden";

		$("#history_loader").show();
		if (null != getPagerXMLHTTPRequest)
		{
			getPagerXMLHTTPRequest.abort();
		}

		var additionalCheckParameters = getAdditionalCheckParameters();
		getPagerXMLHTTPRequest = $.ajax({
				type: "POST",
				url: "getPager.php",
				data: "domain=" + searchDomain + "&page=" + pageNumber + "&test_type=" + $("#test_type").val() + "&parameters=" + additionalCheckParameters.raw,
				success: function(msg) { getPagerResponse(msg, callback); },
				error: function(XMLHttpRequest, textStatus, errorThrown){statusServerError();}
			});
	}

	function getPagerResponse(msg, callback)
	{
		$("#history_loader").hide();

		var pagerList = $("#pagerlist")[0];
		while (0 < pagerList.childNodes.length) {
			pagerList.removeChild(pagerList.childNodes[0]);
		}

		var response = eval("(" + msg + ")");

		if ('ERROR' == response.status ||
			'INTERNAL_ERROR' == response.status)
		{
			statusServerError();
			return;
		}
		else
		{
			$('#pager_error').hide();
			$('#pagerbuttonsdiv').show();
			$('#pagerlist').show();
		}

		if ('ERROR_DOMAIN_DOES_NOT_EXIST' == response['status'])
		{
			statusDomainDoesNotExist();
			return;
		}

		if('ERROR_DOMAIN_SYNTAX' == response['status'])
		{
			statusDomainSyntax();
		}

		if('ERROR_NO_NAMESERVERS' == response['status'])
		{
			statusNoNameservers();
		}

		for (var i = 0; i < response['history'].length; i++)
		{
			var li = document.createElement("li");
			var a = document.createElement("a");

			a.href = "?time=" + response['history'][i]['time'] + "&id=" + response['history'][i]['id'] + "&view=basic" + "&lang=" + languageId + "&test=" + $("#test_type").val();
			a.className = response['history'][i]['class'];
			a.innerHTML = formatDate(response['history'][i]['time']);
			a.historyId = response['history'][i]['id'];
			a.onclick = getHistoryItem;

			li.appendChild(a);
			$("#pagerlist")[0].appendChild(li);
		}

		if (0 < response['history'].length)
		{
			$('#pager_no_history').hide();
		}
		else
		{
			$('#pager_no_history').show();
		}

		$("#pagerlabel")[0].innerHTML = response['pageNumber'] + "/" + response['totalPages'];
		currentPage = parseInt(response['pageNumber']);
		totalPages = parseInt(response['totalPages']);
		$("#pagerstart").attr("src", "_img/pager_start_" + ((1 < currentPage) ? "on" : "off") + ".png");
		$("#pagerback").attr("src", "_img/pager_back_" + ((1 < currentPage) ? "on" : "off") + ".png");
		$("#pagerforward").attr("src", "_img/pager_forward_" + ((currentPage < totalPages) ? "on" : "off") + ".png");
		$("#pagerend").attr("src", "_img/pager_end_" + ((currentPage < totalPages) ? "on" : "off") + ".png");

		document.getElementById("pagerlist").style.visibility = "";

		if (null != callback)
		{
			callback();
		}
	}

	function formatDate(timestamp)
	{
		var dateObj = new Date();
		dateObj.setTime(timestamp * 1000);
		var formattedDate = dateObj.getFullYear() + '-' + leadZero(dateObj.getMonth() + 1) + '-' + leadZero(dateObj.getDate()) +
		                    ' ' + leadZero(dateObj.getHours()) + ':' + leadZero(dateObj.getMinutes()) + ':' + leadZero(dateObj.getSeconds());
		return formattedDate;
	}

	function leadZero(num)
	{
		num = parseInt(num);
		if (10 > num)
		{
			num = '0' + num;
		}

		return num;
	}

	function getHistoryItem()
	{
		var historyId = this.historyId;
		$("#result_loader").show();
		statusLoading();
		getResult(historyId);

		return false;
	}

	function getAdditionalCheckParameters(){
		var additionalParameters = {};
		additionalParameters.status = 'OK';
		additionalParameters.raw = '';
		switch ($("#test_type").val()) {
			case 'undelegated':
				// Get nameservers and ips in a format hostname/IP hostname/IP
				var nameservers = Array();
				$("div.nameserver").each(function(){
					var newOne = {};
					newOne.host = $(this).children("[name=nameserver_host]").val();
					newOne.ip = $(this).children("[name=nameserver_ip]").val();

					if(newOne.host.trim().length > 0){
						nameservers.push(newOne);
					}
				});

				if(nameservers.length == 0){
					additionalParameters.status = 'ERROR';
					additionalParameters.raw = '';
				}
				else{
					var length = nameservers.length;
					for(var i =0; i < length; i++){
						var one = nameservers[i];
						additionalParameters.raw = additionalParameters.raw + one.host;
						if(one.ip.trim().length > 0){
							additionalParameters.raw = additionalParameters.raw + "/" + one.ip;
						}

						additionalParameters.raw += " ";
					}
				}
				break;
			default:
				break;
		}

		return additionalParameters;
	}

	function getResult(historyId)
	{
		if (null != getResultTimeoutVar)
		{
			clearTimeout(getResultTimeoutVar);
		}

		clearTree();

		if (null != getResultXMLHTTPRequest)
		{
			getResultXMLHTTPRequest.abort();
		}

		var additionalCheckParameters = getAdditionalCheckParameters();
		
		getResultXMLHTTPRequest = $.ajax({
			type: "POST",
			url: "getResult.php",
			data: "domain=" + searchDomain + "&test=" + $("#test_type").val() + "&lang=" + languageId + ((null != historyId) ? "&historyId=" + historyId : "" + "&parameters=" + additionalCheckParameters.raw),
			error: function(XMLHttpRequest, textStatus, errorThrown){statusServerError();},
			success: function(msg)
			{
				var response = eval("(" + msg + ")");
				
				if ('IN_PROGRESS' == response['result'])
				{
					totalMillis = totalMillis + 1000;
					
					if(totalMillis < (guiTimeout * 1000)){
						getResultTimeoutVar = setTimeout('getResult(' + historyId + ')', 1000);
					}
					else {
						statusServerError();
					}
					return;
				}
				
				if(response['result'] == 'INTERNAL_ERROR'){
					statusServerError();
					return;
				}

				var baseUrl = window.location.protocol + "//" + window.location.host + window.location.pathname;

				populateTree(response['tree'], $("#treediv")[0], true);
				appendPermalink($("#treediv")[0], baseUrl + "?time=" + response['time'] + "&id=" + response['id'] + "&view=basic" + "&test=" + test);
				populateTree(response['list'], $("#listdiv")[0], false);
				appendPermalink($("#listdiv")[0], baseUrl + "?time=" + response['time'] + "&id=" + response['id'] + "&view=advanced" + "&test=" + test);
				
				document.thisId = response['id'];
				document.thisTime = response['time'];
				
				$("#result_loader").hide();
				$("#undelegateddomain_info").show();

				switch(response['result'])
				{
					case 'OK':
						statusOk(response['domain'], response['time'], response['dnscheckversion']);
						break;
					case 'WARNING':
						statusWarn(response['domain'], response['time'], response['dnscheckversion']);
						break;
					case 'ERROR':
						statusError(response['domain'], response['time'], response['dnscheckversion']);
						break;
				}

				// Fill in additional parameters from source data
				var sourceData = response.sourceData;
				if(historyId != null){
					removeAllNameservers();
					var nameserversAndIps = sourceData.split(" ");
					var l = nameserversAndIps.length;
					for(var i = 0; i < l; i++){
						if(nameserversAndIps[i].length > 0){
							var nameserverAndIp = nameserversAndIps[i].split('/');
							var nameserver = nameserverAndIp[0];
							var ip = '';
							if(nameserverAndIp.length > 1){
								ip = nameserverAndIp[1];
							}

							addNameserver(nameserver, ip);
						}
					}

					removeFirstNameserver();
				}
			}
		});
	}

	function appendPermalink(parentElement, permalink)
	{
		var p = document.createElement('p');
		p.id = 'permalink';
		p.innerHTML = "<strong>" + document.getElementById("link_to_test_label").innerHTML + "</strong><br /><a href=\"" + permalink + "\">" + permalink + "</a>";

		parentElement.appendChild(p);
	}

	function activateSimpleTab()
	{
		$("#simpletab")[0].className = "tab_on";
		$("#advancedtab")[0].className = "";
		$("#treediv").show();
		$("#listdiv").hide();
	}

	function activateAdvancedTab()
	{
		$("#simpletab")[0].className = "";
		$("#advancedtab")[0].className = "tab_on";
		$("#treediv").hide();
		$("#listdiv").show();
	}

	function statusDomainDoesNotExist()
	{
		$("#resultwrapper").slideUp("slow");

		$("#status_light")[0].className = "mainerror";
		$("#result_status").slideDown("slow");
		$("#status_header")[0].innerHTML = domainDoesNotExistHeader;
		$("#status_text")[0].innerHTML = domainDoesNotExistLabel;
	}
	
	function statusServerError()
	{
		$("#resultwrapper").slideUp("slow");

		$("#status_light")[0].className = "loaderror";
		$("#result_status").slideDown("slow");
		$("#status_header")[0].innerHTML = loadErrorHeader;
		$("#status_text")[0].innerHTML = loadErrorLabel;
	}

	function statusDomainSyntax()
	{
		$("#resultwrapper").slideUp("slow");

		$("#status_light")[0].className = "mainerror";
		$("#result_status").slideDown("slow");
		$("#status_header")[0].innerHTML = domainSyntaxHeader;
		$("#status_text")[0].innerHTML = domainSyntaxLabel;
	}

	function statusNoNameservers()
	{
		$("#resultwrapper").slideUp("slow");

		$("#status_light")[0].className = "mainerror";
		$("#result_status").slideDown("slow");
		$("#status_header")[0].innerHTML = noNameserversHeader;
		$("#status_text")[0].innerHTML = noNameserversLabel;
	}

	function statusLoading()
	{
		$("#status_light")[0].className = "mainload";
		$("#result_status").slideDown("slow");
		$("#status_header")[0].innerHTML = loadingHeader;
		$("#status_text")[0].innerHTML = loadingLabel;
	}

	function statusOk(domain, timestamp, version)
	{
		$("#status_light")[0].className = "mainok";
		$("#result_status").slideDown("slow");
		$("#status_header")[0].innerHTML = okHeader;
		$("#status_text")[0].innerHTML = domain + ', ' + formatDate(timestamp) + '<br />' + labelVersion + version;
	}

	function statusWarn(domain, timestamp, version)
	{
		$("#status_light")[0].className = "mainwarn";
		$("#result_status").slideDown("slow");
		$("#status_header")[0].innerHTML = warningHeader;
		$("#status_text")[0].innerHTML = domain + ', ' + formatDate(timestamp) + '<br />' + labelVersion + version;
	}

	function statusError(domain, timestamp, version)
	{
		$("#status_light")[0].className = "mainerror";
		$("#result_status").slideDown("slow");
		$("#status_header")[0].innerHTML = errorHeader;
		$("#status_text")[0].innerHTML = domain + ', ' + formatDate(timestamp + '<br />' + labelVersion + version);
	}

	function startTest()
	{
		searchDomain = $("#domaininput").attr("value");
		currentPage = 1;
		totalPages = 1;

		var permalinkIdTemp = permalinkId;
		permalinkId = null;
		$("#startwrapper").slideUp("slow", function(){
			$("#resultwrapper").slideUp("slow", function(){
				statusLoading();
				refreshPager(currentPage, function()
					{
						$("#result").show();
						getResult(permalinkIdTemp);
						$("#resultwrapper").slideDown("slow");
					}
				);
			});
		});
	}

	function addNameserver(hostname, ip){
		var newElement = $("#nameservers div:last").cloneWithEvents(true);
		newElement.children("input:first").val(hostname);
		newElement.children("input:last").val(ip);
		newElement.appendTo("#nameservers");

		// Show button from all except the last one
		$("#nameservers > div > a").show();

		if($("div.nameserver").size() == 30){
			// Remove add button link
			$("#addnameserver").hide();
		}
	}

	function removeAllNameservers(){
		$("#nameservers div:not(:last)").remove();
	}

	function removeFirstNameserver(){
		$("#nameservers div:first").remove();
	}

	function resolveHostname(){
		var nameservers = '';
		$("div.nameserver").each(function(){
			var host = $(this).children("[name=nameserver_host]").val();

			if(host.trim().length > 0){
				nameservers = nameservers + host + '|';
			}
		});
		
		var toPutInto = $(this).parent().children("input:last");
		var hostname = $(this).val();
		$.post('resolveHostname.php', {nameservers:nameservers, hostname:hostname}, function(data){
			if(toPutInto.val().length == 0){
				if(hostname != data){
					toPutInto.val(data);
				}
			}
		});
	}

	$(document).ready(function(){
		$("#addnameserver").click(function(){
			addNameserver('', '');
		});
		
		$("a.removenameserver").click(function(){
			$(this).parent().remove();
			
			// If there is only one nameserver left, remove the remove button
			if($("div.nameserver").size() == 1){
				$("#nameservers > div > a").hide();
			}
		});
		
		$("[name=nameserver_host]").blur(resolveHostname);
		$("#testnow").click(startTest);
		$("#mainform").submit(function() { startTest(); return false; });
		$("#pagerstart").click(function() { if (1 < currentPage) { refreshPager(1, null); } });
		$("#pagerback").click(function() { if (1 < currentPage) { refreshPager(currentPage - 1, null); } });
		$("#pagerforward").click(function() { if (currentPage < totalPages) { refreshPager(currentPage + 1, null); } });
		$("#pagerend").click(function() { if (currentPage < totalPages) { refreshPager(totalPages, null); } });

		if (null != permalinkId)
		{
			startTest();
			if (1 == permalinkView)
			{
				activateSimpleTab();
			}
			else
			{
				activateAdvancedTab();
			}
		}

	});



