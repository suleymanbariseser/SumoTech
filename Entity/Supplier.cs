using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class Supplier
    {
        public int Id { get; set; }
        public string Address { get; set; }
        public List<Item> List { get; set; }
    }
}