String getTitleFromType(String typeReport) {
  switch (typeReport) {
    case 'TRAFFIC_JAM':
      return 'Traffic Jam';
    case 'FLOOD':
      return 'Flooding';
    case 'ACCIDENT':
      return 'Traffic Accident';
    default:
      return 'Traffic Notification';
  }
}
