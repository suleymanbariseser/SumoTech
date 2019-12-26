using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SumoTech.Entity
{
    public class Item
    {
        public int Id { get; set; }   
        public String Image { get; set; }
        public String Brand { get; set; }
        public String Name { get; set; }
        public double Price { get; set; }
        public int Production_year { get; set; }
        public String Description { get; set; }
        public String Type { get; set; }
    }
}