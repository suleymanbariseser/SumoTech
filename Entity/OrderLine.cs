using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class OrderLine
    {
        public int Id { get; set; }
        public double Price { get; set; }
        public DateTime Date { get; set; }
        public List<Item> List { get; set; }

    }
}