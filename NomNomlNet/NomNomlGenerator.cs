using NomNomlNet.Enumerates;
using NomNomlNet.Snippets;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace NomNomlNet
{
   public class NomNomlGenerator
    {
        private static readonly Regex scriptTagRegex = new Regex("script", RegexOptions.IgnoreCase | RegexOptions.Multiline);

        public static string Generate(List<Node> nodesList, List<Relationship> relationshipList, Lane lane)
       {
           StringBuilder sb = new StringBuilder();

           foreach (Node node in nodesList)
           {
               switch (node.Type)
               {
                   case NodeType.Normal:
                       sb.Append("[" + node.Name + "]");
                       break;
                   case NodeType.Start:
                       sb.Append("[<start>" + node.Name + "]");
                       break;
                   case NodeType.End:
                       sb.Append("[<end>" + node.Name + "]");
                       break;
                   case NodeType.Decision:
                       sb.Append("[<choice>" + node.Name + "]");
                       break;
                   case NodeType.State:
                       sb.Append("[<state>" + node.Name + "]");
                       break;
               }
               sb.Append("\r\n");
           }

           foreach (Relationship relationship in relationshipList)
           {
               switch (relationship.RelationshipType)
               {
                   case RelationshipType.Simple:
                       sb.Append("[" + relationship.Source + "]->[" + relationship.Target + "]");
                       break;
                   case RelationshipType.Dependency:
                       sb.Append("[" + relationship.Source + "]-->[" + relationship.Target + "]");
                       break;
                   case RelationshipType.Comment:
                       sb.Append("[" + relationship.Source + "]" + relationship.Comment + " ->[" + relationship.Target + "]");
                       break;
                   case RelationshipType.Note:
                       sb.Append("[" + relationship.Source + "]--[<note>" + relationship.Note + "]");
                       break;
               }
               sb.Append("\r\n");
           }

           string script = sb.ToString();

           if (lane != null)
           {
               script = "[" + lane.Name + "|" + sb.ToString() + "]";
           }

           return JavaScriptStringLiteral(script);
       }

        public static string JavaScriptStringLiteral(string str)
        {
            var sb = new StringBuilder();
            //sb.Append("\"");
            foreach (char c in str)
            {
                switch (c)
                {
                    case '\"':
                        sb.Append("\\\"");
                        break;
                    case '\'':
                        sb.Append("\\\'");
                        break;
                    case '\\':
                        sb.Append("\\\\");
                        break;
                    case '\b':
                        sb.Append("\\b");
                        break;
                    case '\f':
                        sb.Append("\\f");
                        break;
                    case '\n':
                        sb.Append("\\n");
                        break;
                    case '\r':
                        sb.Append("\\r");
                        break;
                    case '\t':
                        sb.Append("\\t");
                        break;
                    default:
                        int i = (int)c;
                        if (i < 32 || i > 127)
                        {
                            sb.AppendFormat("\\u{0:X04}", i);
                        }
                        else
                        {
                            sb.Append(c);
                        }
                        break;
                }
            }
            // sb.Append("\"");

            return scriptTagRegex.Replace(
                sb.ToString(),
                m => (m.Value[0] == 's' ? "\\u0073" : "\\u0053") + m.Value.Substring(1));
        }
    }
}
