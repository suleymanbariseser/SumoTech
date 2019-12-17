using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class Factory
    {
        public int Id { get; set; }
        public String Address { get; set; }
        public int ProductionCapacity { get; set; }
        public List<HouseHold> List { get; set; }
    }
}