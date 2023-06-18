/// module for animations
module ysge.animation;

import std.algorithm;
import ysge.project;

/// structure for animations
struct Animation {
	RenderInfo[] frames;      /// each frame of the animation
	int          updateTicks; /// how long a frame will stay on
}

/// structure for ongoing animations
struct AnimationProcess {
	int         animation;
	size_t      frame;
	RenderInfo* target;
}

/// used for managing animations
class AnimationManager {
	Animation[int]     animations;
	AnimationProcess[] processes;

	/// creates a new animation
	void CreateAnimation(int id, RenderInfo[] frames) {
		animations[id] = Animation(frames);
	}

	/// sets a texture to be animated
	void StartAnimation(RenderInfo* target, int animation) {
		foreach (i, ref process ; processes) {
			if (process.target == target) {
				processes = processes.remove(i);
				break;
			}
		}
	
		AnimationProcess process = AnimationProcess(
			animation, 0, target
		);

		*process.target = animations[animation].frames[0];

		processes ~= process;
	}

	/// stops an animation
	void StopAnimation(int animation) {
		foreach (i, ref process ; processes) {
			if (process.animation == animation) {
				processes = processes.remove(i);
				break;
			}
		}

		throw new ProjectException("Animation already stopped");
	}

	/// checks if an animation is running
	bool IsAnimationRunning(int animation) {
		foreach (ref process ; processes) {
			if (process.animation == animation) {
				return true;
			}
		}

		return false;
	}

	AnimationProcess GetProcess(int animation) {
		foreach (ref process ; processes) {
			if (process.animation == animation) {
				return process;
			}
		}

		throw new ProjectException("Could not find animation process");
	}

	void Update(Project project, Scene scene) {
		foreach (ref process ; processes) {
			auto animationData = animations[process.animation];

			if (project.frames % animationData.updateTicks == 0) {
				process.frame = (process.frame + 1) % animationData.frames.length;

				*process.target = animationData.frames[process.frame];
			}
		}
	}
}
