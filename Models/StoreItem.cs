using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Web;

namespace SumoTech.Models
{
    public class StoreItem
    {
        [Required]
        public int Storeid { get; set; }
        [Required]
        public int Itemid { get; set; }
        [Required]
        public int Quantity { get; set; }
    }
}