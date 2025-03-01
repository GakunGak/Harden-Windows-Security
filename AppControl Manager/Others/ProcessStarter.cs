﻿using System;
using System.Diagnostics;

namespace AppControlManager.Others;

internal static class ProcessStarter
{
	/// <summary>
	/// Executes an executable with arguments
	/// </summary>
	/// <param name="command"></param>
	/// <param name="arguments"></param>
	/// <exception cref="InvalidOperationException"></exception>
	internal static void RunCommand(string command, string? arguments = null)
	{

		ProcessStartInfo processInfo;

		if (arguments is not null)
		{
			processInfo = new()
			{
				FileName = command,
				Arguments = arguments,
				RedirectStandardOutput = true,
				RedirectStandardError = true,
				UseShellExecute = false,
				CreateNoWindow = true
			};
		}
		else
		{
			processInfo = new()
			{
				FileName = command,
				RedirectStandardOutput = true,
				RedirectStandardError = true,
				UseShellExecute = false,
				CreateNoWindow = true
			};
		}

		using Process process = new();
		process.StartInfo = processInfo;
		_ = process.Start();

		// Capture output and errors
		string output = process.StandardOutput.ReadToEnd();
		string error = process.StandardError.ReadToEnd();

		process.WaitForExit();

		if (process.ExitCode is not 0)
		{
			throw new InvalidOperationException($"Command '{command} {arguments}' failed with exit code {process.ExitCode}. Error: {error}");
		}
	}

	/// <summary>
	/// Executes an executable with arguments and returns the output
	/// </summary>
	/// <param name="command"></param>
	/// <param name="arguments"></param>
	/// <returns>Standard output of the executed command</returns>
	/// <exception cref="InvalidOperationException"></exception>
	internal static string RunCommandWithOutput(string command, string? arguments = null)
	{
		ProcessStartInfo processInfo = new()
		{
			FileName = command,
			Arguments = arguments ?? string.Empty,
			RedirectStandardOutput = true,
			RedirectStandardError = true,
			UseShellExecute = false,
			CreateNoWindow = true
		};

		using Process process = new() { StartInfo = processInfo };
		_ = process.Start();

		string output = process.StandardOutput.ReadToEnd();
		string error = process.StandardError.ReadToEnd();
		process.WaitForExit();

		if (process.ExitCode is not 0)
		{
			throw new InvalidOperationException($"Command '{command} {arguments}' failed with exit code {process.ExitCode}. Error: {error}");
		}

		return output;
	}
}
