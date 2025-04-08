String getTimeAgo(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);

  if (difference.inMinutes < 1) return 'Just now';
  if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
  if (difference.inHours < 24) return '${difference.inHours}h ago';
  if (difference.inDays < 30) return '${difference.inDays}d ago';
  if (difference.inDays < 365) {
    return '${(difference.inDays / 30).floor()}mo ago';
  }
  return '${(difference.inDays / 365).floor()}y ago';
}
