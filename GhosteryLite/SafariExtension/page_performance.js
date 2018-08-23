/**
 * Ghostery Page Performance
 *
 * This file generates page-level metrics using the
 * Web Performance API. It is called via background.js `onNavigationCompleted()`.
 *
 * https://developer.mozilla.org/en-US/docs/Web/API/Window/performance
 *
 * Ghostery Safari App Extension
 * https://www.ghostery.com/
 *
 * Copyright 2018 Ghostery, Inc. All rights reserved.
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0
 */
const PageInfo = (function(window, document) {
	let state = document.readyState;
	/**
	 * Calculate page domain and latency
	 */
	const analyzePageInfo = function() {
		const { host, pathname, protocol } = document.location;
		// Note: Safari has limited support for PerformanceTimingAPI properties
		const unfixedLatency = Number(performance.timing.domComplete - performance.timing.navigationStart) / 1000;
		let pageLatency = 0;

		if (unfixedLatency >= 100) { // > 100 no decimal 
			pageLatency = unfixedLatency.toFixed(); 
		} else if (unfixedLatency >= 10 && unfixedLatency < 100) { // 100 > 10 use one decimal 
			pageLatency = unfixedLatency.toFixed(1); 
		} else if (unfixedLatency < 10) { // < 10s use two decimals 
			pageLatency = unfixedLatency.toFixed(2); 
		}

		console.log('Sending latency from page_performance', pageLatency);

		safari.extension.dispatchMessage('recordPageInfo', {
			domain: `${protocol}//${host}${pathname}`,
			latency: pageLatency
		});
	};

	/**
	 * Initialize functionality of this script
	 */
	const _initialize = function() {
		// manually check to see if the onLoad event has fired
		if (state !== 'complete') {
			document.onreadystatechange = function() {
				state = document.readyState;
				if (state === 'complete') {
					analyzePageInfo();
				}
			};
		} else {
			analyzePageInfo();
		}
	};

	return {
		/**
		 * Public API
		 */
		init() {
			// only load on top-level domains
			if (window.top !== window.parent) {
				return;
			}
			_initialize();
		}
	};
}(window, document));


PageInfo.init();
