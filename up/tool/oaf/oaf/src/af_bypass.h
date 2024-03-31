#ifndef __AF_BYPASS_H__
#define __AF_BYPASS_H__

static inline int bypassed_interface(struct net_device *in)
{
	if (0 == strncmp(in->name, "br-lan", 6)){
		return 0;
	}
	else{
		return 1;
	}
}

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,4,0)
#define BYPASS_PACKET() (bypass_packet(skb))
static inline int bypass_packet(struct sk_buff *skb) {
#else
#define BYPASS_PACKET() (bypass_packet(skb, in))
static inline int bypass_packet(struct sk_buff *skb, const struct net_device *in) {
#endif
	int bypassed = 0;
// 4.10-->4.11 nfct-->_nfct
#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,11,0)
	struct nf_conn *ct = (struct nf_conn *)skb->_nfct;
#else
	struct nf_conn *ct = (struct nf_conn *)skb->nfct;
#endif
	if (ct == NULL) {
		return 1;
	}

	// for HTTP GET / or HTTPS clien-hello, just a trick
	if (skb->len < 67 || skb->len > 1200)
		return 1;

#if LINUX_VERSION_CODE >= KERNEL_VERSION(4,4,0)
	if(!skb->dev)
		return 1;

	bypassed = bypassed_interface(skb->dev);
#else
	if (!in){
		AF_ERROR("in is NULL\n");
		return 1;
	}
	bypassed = bypassed_interface(in);
#endif

	if (bypassed)
		return 1;

	return 0;
}

#endif