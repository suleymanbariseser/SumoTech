using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class HouseHold
    {
        public Item Item { get; set; }
        public Factory Factory { get; set; }
        public String applienceType { get; set; }
        public String applienceProductivity { get; set; }
    }
}
