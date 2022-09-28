(() => {
    // this mutation observer watches for new plots and grows the window accordingly
    const observer = new MutationObserver((mutationList, observer) => {
        const w0 = window.innerWidth
        const h0 = window.innerHeight
        let w1 = w0
        let h1 = h0
        for (const mutation of mutationList) {
            if (mutation.type === 'childList') {
                for (const node of mutation.addedNodes) {
                    if ((node.tagName === 'DIV') && node.classList.contains('bk')) {
                        w1 = Math.max(w1, node.clientWidth)
                        h1 = Math.max(h1, node.clientHeight)
                    }
                }
            }
        }
        const dw = Math.max(w1 - w0, 0)
        const dh = Math.max(h1 - h0, 0)
        if ((dw > 0) || (dh > 0)) {
            window.resizeBy(dw, dh)
        }
    })
    observer.observe(document.querySelector('body'), {childList: true, subtree: true})

    // save stuff
    window.BokehBlink = {
        observer: observer,
    }
})()
