#!/usr/bin/env python3
"""
MiniMax Token Plan — 视频生成
POST /v1/video_generation
支持：文生视频、图生视频、首尾帧视频、主体参考视频
"""
import argparse, sys, os, time
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from utils import BASE_URL, get_api_key, download_file, upload_file

import requests

def video_gen(
    model: str = "MiniMax-Hailuo-2.3",
    prompt: str = None,
    image: str = None,
    first_frame: str = None,
    last_frame: str = None,
    subject_image: str = None,
    duration: int = 6,
    resolution: str = "768P",
    output: str = "output.mp4",
    poll_interval: int = 10,
    timeout: int = 600,
    fast_pretreatment: bool = False,
    prompt_optimizer: bool = True,
):
    url = f"{BASE_URL}/v1/video_generation"
    headers = {
        "Authorization": f"Bearer {get_api_key()}",
        "Content-Type": "application/json"
    }

    def upload_img(path):
        if path:
            r = upload_file(path)
            return str(r.get("file_id", ""))
        return None

    payload = {
        "model": model,
        "prompt": prompt or "",
        "duration": duration,
        "resolution": resolution,
        "prompt_optimizer": prompt_optimizer,
    }

    if image:
        img_id = upload_img(image)
        if img_id:
            payload["image"] = img_id

    if first_frame:
        ff_id = upload_img(first_frame)
        if ff_id:
            payload["first_frame"] = ff_id

    if last_frame:
        lf_id = upload_img(last_frame)
        if lf_id:
            payload["last_frame"] = lf_id

    if subject_image:
        si_id = upload_img(subject_image)
        if si_id:
            payload["subject_image"] = si_id

    if fast_pretreatment:
        payload["fast_pretreatment"] = True

    print(f"🎬 创建视频生成任务...")
    print(f"   模型: {model} | 分辨率: {resolution} | 时长: {duration}s")
    if prompt:
        print(f"   Prompt: {prompt[:80]}{'...' if len(prompt)>80 else ''}")

    resp = requests.post(url, headers=headers, json=payload, timeout=60)
    resp.raise_for_status()
    result = resp.json()

    base = result.get("base_resp", {})
    if base.get("status_code") != 0 and base.get("status_code") is not None:
        print(f"❌ 创建失败: {base.get('status_msg')}")
        print(f"   完整响应: {result}")
        return

    task_id = result.get("task_id")
    print(f"✅ 任务已创建: {task_id}")
    print(f"⏳ 等待生成完成（轮询间隔 {poll_interval}s）...")

    start = time.time()
    query_url = f"{BASE_URL}/v1/video_generation"

    while time.time() - start < timeout:
        resp = requests.get(query_url, headers=headers, params={"task_id": task_id}, timeout=30)
        resp.raise_for_status()
        result = resp.json()

        base = result.get("base_resp", {})
        status = base.get("status")

        if status == 2:
            data = result.get("data", {})
            video_url = data.get("video_url") or data.get("audio_url")  # 有时字段名不同
            if video_url:
                download_file(video_url, output)
            else:
                print(f"✅ 任务完成，但未返回视频URL: {result}")
            print(f"✅ 视频已保存: {output}")
            return
        elif status == 3:
            raise RuntimeError(f"视频生成失败: {result}")
        elif status == 1:
            print(f"  生成中... ({int(time.time()-start)}s) 状态=处理中")
        else:
            print(f"  状态: {status}")

        time.sleep(poll_interval)

    raise TimeoutError(f"视频生成超时（{timeout}s）")


def main():
    p = argparse.ArgumentParser(description="MiniMax 视频生成（文生/图生/首尾帧/主体参考）")
    p.add_argument("--model", "-m", default="MiniMax-Hailuo-2.3",
                   choices=["MiniMax-Hailuo-2.3","MiniMax-Hailuo-02",
                             "T2V-01-Director","T2V-01"],
                   help="视频模型")
    p.add_argument("--prompt", required=True, help="视频描述文本（≤2000字）")
    p.add_argument("--image", help="图生视频：输入图片路径")
    p.add_argument("--first-frame", help="首尾帧视频：首帧图片路径")
    p.add_argument("--last-frame", help="首尾帧视频：尾帧图片路径")
    p.add_argument("--subject-image", help="主体参考视频：人物图片路径")
    p.add_argument("--duration", type=int, choices=[6, 10], default=6, help="视频时长（秒）")
    p.add_argument("--resolution", default="768P",
                   choices=["720P","768P","1080P"],
                   help="分辨率")
    p.add_argument("--output", "-o", default="output.mp4")
    p.add_argument("--poll-interval", type=int, default=10)
    p.add_argument("--timeout", type=int, default=600)
    p.add_argument("--no-prompt-optimizer", action="store_true", help="禁用 prompt 自动优化")
    args = p.parse_args()

    if args.first_frame and not args.last_frame:
        print("⚠️ 提供了 --first-frame 但缺少 --last-frame，将作为图生视频处理")
    if args.subject_image and args.image:
        print("⚠️ 同时提供了 --subject-image 和 --image，将使用 --subject-image")

    video_gen(
        model=args.model,
        prompt=args.prompt,
        image=args.image,
        first_frame=args.first_frame,
        last_frame=args.last_frame,
        subject_image=args.subject_image,
        duration=args.duration,
        resolution=args.resolution,
        output=args.output,
        poll_interval=args.poll_interval,
        timeout=args.timeout,
        prompt_optimizer=not args.no_prompt_optimizer,
    )

if __name__ == "__main__":
    main()
