public class Example
{
	public static String findId(String text, String delimiter)
	{
		int lastIndex = text.lastIndexOf(delimiter);
		if (lastIndex != -1) return text.substring(0, lastIndex);
		else return text;
	}
}
