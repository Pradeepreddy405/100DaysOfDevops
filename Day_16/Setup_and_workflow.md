\###  Setup and workflow

                    Client

&#x20;                     |

&#x20;                     | HTTP :80

&#x20;                     v

&#x20;             +----------------+

&#x20;             |     stlb01      |

&#x20;             |     Nginx       |

&#x20;             |  Load Balancer  |

&#x20;             +--------+-------+

&#x20;                      |

&#x20;         +------------+------------+

&#x20;         |            |            |

&#x20;         v            v            v

&#x20;    stapp01       stapp02       stapp03

&#x20;     Apache         Apache        Apache

&#x20;      :PORT          :PORT         :PORT

&#x20;         |            |            |

&#x20;         +------------+------------+

&#x20;                      |

&#x20;                   Website

