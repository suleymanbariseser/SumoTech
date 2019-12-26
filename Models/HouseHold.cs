using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class HouseHold : Item
    {
        [Required]
        public int Factoryid { get; set; }
        [Required]
        public String ApplienceType { get; set; }
        [Required]
        public String ApplienceProductivity { get; set; }
    }
}
